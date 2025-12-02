resource "azurerm_resource_group" "main" {
  for_each = var.resource_groups
  name     = each.value.name
  location = each.value.location
}

resource "azurerm_virtual_network" "main" {
  for_each            = var.vnets
  name                = each.value.name
  address_space       = each.value.address_space
  location            = var.resource_groups[each.value.resource_group_key].location
  resource_group_name = var.resource_groups[each.value.resource_group_key].name
  depends_on = [ azurerm_resource_group.main ]
}

resource "azurerm_network_security_group" "main" {
  for_each = var.nsgs
  name     = each.value.name
  location = var.resource_groups[each.value.resource_group_key].location
  resource_group_name = var.resource_groups[each.value.resource_group_key].name

  dynamic "security_rule" {
    for_each = each.value.rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

resource "azurerm_subnet" "subnets" {
  for_each = var.subnets
  name                 = each.value.name
  resource_group_name  = var.resource_groups[var.vnets[each.value.vnet_key].resource_group_key].name
  virtual_network_name = var.vnets[each.value.vnet_key].name
  address_prefixes     = [each.value.address_prefix]

  dynamic "delegation" {
    // Exclude delegations that target Microsoft.ContainerService/managedClusters (invalid for AKS node subnets)
    for_each = [
      for d in lookup(each.value, "delegations", []) :
      d if d.service_delegation.name != "Microsoft.ContainerService/managedClusters"
    ]
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
  depends_on = [ azurerm_virtual_network.main ]
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
  for_each = {
    for sk, s in var.subnets : sk => s if lookup(s, "nsg_key", null) != null
  }
  subnet_id = azurerm_subnet.subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.main[each.value.nsg_key].id
  
  depends_on = [ azurerm_subnet.subnets, azurerm_network_security_group.main ]
}