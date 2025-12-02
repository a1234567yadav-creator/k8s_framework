# Azure
azure_subscription_id      = "8a9e53c0-726c-4a09-815e-3de9449bf21b"
azure_tenant_id            = "7c0c36f5-af83-4c24-8844-9962e0163719"
location                   = "eastus"

resource_groups = {
  rg-hub   = { name = "rg-hub",   location = "eastus" }
  rg-spoke = { name = "rg-spoke", location = "eastus" }
}

nsgs = {
  hub-nsg = {
    name               = "hub-nsg"
    resource_group_key = "rg-hub"
    rules = [
      {
        name                       = "AllowAzureServices"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "AzureLoadBalancer"
        destination_address_prefix = "*"
      }
    ]
  }
  aks-nsg = {
    name               = "aks-nsg"
    resource_group_key = "rg-spoke"
    rules = [
      {
        name                       = "AllowAKSNodePorts"
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "30000-32767"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  }
}

vnets = {
  vnet-spoke = {
    name               = "vnet-spoke"
    address_space      = ["10.10.0.0/16"]
    resource_group_key = "rg-spoke"
  }
}

subnets = {
  aks-subnet = {
    name           = "aks-subnet"
    vnet_key       = "vnet-spoke"
    address_prefix = "10.10.2.0/24"
    nsg_key        = "aks-nsg"
    delegations    = [
      {
        name = "aks-delegation"
        service_delegation = {
          name    = "Microsoft.ContainerService/managedClusters"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      }
    ]
  }
  app-subnet = {
    name           = "app-subnet"
    vnet_key       = "vnet-spoke"
    address_prefix = "10.10.3.0/24"
  }
}

# aks_clusters = {
#   aks-anywhere = {
#     resource_group_name             = "rg-spoke"
#     location                        = "eastus"
#     cluster_name                    = "aks-anywhere-01"
#     dns_prefix                      = "aksanywhere"
#     agent_count                     = 1
#     vm_size                         = "Standard_DS2_v2"
#     vnet_name                       = "vnet-spoke"
#     subnet_name                     = "app-subnet"
#     tags                            = { env = "dev", owner = "platform" }
#     # Leave version unset to use a supported default in the region
#     private_cluster_enabled         = false
#     # Empty list means public endpoint accessible from anywhere
#     api_server_authorized_ip_ranges = []
#     node_pool_max_pods              = 30
#     node_pool_availability_zones    = []
#     network_plugin                  = "azure"
#     network_policy                  = null
#     enable_azure_policy             = false
#     enable_monitoring               = true
#     admin_group_object_ids          = []
#     maintenance_window              = {
#       day_of_week = "Tuesday"
#       start_hour  = 3
#       duration    = 2
#     }
#     azure_ad_integrated    = false      # Use local kubeconfig authentication only
#     local_account_disabled = false      # Keep local admin credentials enabled
#   }
  # Re-enable prod cluster if needed and add role assignments similarly.
  # aks-prod = {
  #   resource_group_name             = "rg-spoke"
  #   location                        = "eastus"
  #   cluster_name                    = "aks-prod"
  #   dns_prefix                      = "aksprod"
  #   agent_count                     = 3
  #   vm_size                         = "Standard_DS3_v2"
  #   vnet_name                       = "vnet-spoke"
  #   subnet_name                     = "aks-subnet"
  #   tags                            = { env = "prod", owner = "platform" }
  #   # kubernetes_version              = "1.29.3"
  #   api_server_authorized_ip_ranges = ["1.2.3.4/32"]
  #   private_cluster_enabled         = true
  #   node_pool_max_pods              = 30
  #   node_pool_availability_zones    = ["1", "2", "3"]
  #   network_plugin                  = "azure"
  #   network_policy                  = "azure"
  #   enable_azure_policy             = true
  #   enable_monitoring               = true
  #   admin_group_object_ids          = []
  #   maintenance_window              = {
  #     day_of_week = "Monday"
  #     start_hour  = 2
  #     duration    = 4
  #   }
  # }
# }

# AWS
# aws_region = "us-east-1"

# vpcs = {
#   vpc-main = {
#     vpc_cidr = "10.20.0.0/16"
#     public_subnets = {
#       a = { cidr_block = "10.20.1.0/24", az = "us-east-1a" }
#       b = { cidr_block = "10.20.2.0/24", az = "us-east-1b" }
#     }
#     private_subnets = {
#       a = { cidr_block = "10.20.101.0/24", az = "us-east-1a" }
#       b = { cidr_block = "10.20.102.0/24", az = "us-east-1b" }
#     }
#   }
# }

# eks_clusters = {
#   eks-prod = {
#     cluster_name             = "eks-prod"
#     desired_size             = 3
#     max_size                 = 5
#     min_size                 = 3
#     private_subnets          = ["subnet-aaaaaaaa", "subnet-bbbbbbbb"]   # From module aws_vpc outputs
#     eks_security_group_id    = "sg-aaaaaaaa"                           # From module aws_vpc outputs
#     version                  = "1.29"
#     endpoint_private_access  = true
#     endpoint_public_access   = false
#     tags                     = { env = "prod", owner = "platform" }
#     node_instance_type       = "m5.large"
#     node_labels              = { role = "worker" }
#     node_disk_size           = 50
#     node_ami_type            = "AL2_x86_64"
#     node_capacity_type       = "ON_DEMAND"
#     node_group_tags          = { "k8s.io/cluster-autoscaler/enabled" = "true" }
#   }
# }

# # GCP
# gcp_project = "my-gcp-project"
# gcp_region  = "us-central1"

# networks = {
#   vpc-gke = { network_name = "vpc-gke" }
# }

# subnetworks = {
#   gke-subnet = {
#     subnetwork_name = "gke-subnet"
#     subnetwork_cidr = "10.30.1.0/24"
#     region          = "us-central1"
#     network_key     = "vpc-gke"
#   }
# }

# gke_clusters = {
#   gke-prod = {
#     cluster_name                 = "gke-prod"
#     region                       = "us-central1"
#     node_count                   = 3
#     node_machine_type            = "e2-standard-4"
#     node_labels                  = { env = "prod" }
#     node_tags                    = ["gke-node", "prod"]
#     preemptible                  = false
#     disk_size_gb                 = 100
#     network_name                 = "vpc-gke"
#     subnetwork_name              = "gke-subnet"
#     release_channel              = "REGULAR"
#     enable_private_nodes         = true
#     master_authorized_networks   = [
#       { cidr_block = "1.2.3.4/32",  display_name = "corp-admin" }
#     ]
#     logging_service              = "logging.googleapis.com/kubernetes"
#     monitoring_service           = "monitoring.googleapis.com/kubernetes"
#   }
# }