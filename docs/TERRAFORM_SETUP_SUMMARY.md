# Terraform + Backstage Automation Setup Summary

## What Was Created

### 1. GitHub Actions Workflows
- **Location:** `.github/workflows/`
- **Files:**
  - `terraform-plan.yml` - Runs on PRs, validates and plans infrastructure changes
  - `terraform-apply.yml` - Runs on merge to main, applies changes automatically

### 2. Backstage Software Template
- **Location:** `backstage-hexaware/examples/templates/terraform-aks-service/`
- **Components:**
  - `template.yaml` - Template definition with parameters and workflow
  - `content/` - Terraform boilerplate files that get customized per deployment:
    - `main.tf` - Provider and backend configuration
    - `variables.tf` - Input variables with defaults
    - `resources.tf` - AKS cluster, VNet, and subnet resources
    - `outputs.tf` - Terraform outputs
    - `catalog-info.yaml` - Backstage catalog entry
    - `README.md` - Generated documentation

### 3. Terraform Configuration
- **Location:** `terraform/`
- **Files:**
  - `.gitignore` - Excludes state files and .terraform directory
  - Existing modules and configurations preserved

### 4. Documentation
- **Location:** `docs/TERRAFORM_AUTOMATION.md`
- **Contents:**
  - Complete setup guide
  - Prerequisites checklist
  - Usage instructions
  - Troubleshooting tips
  - Best practices

## Prerequisites to Complete

### 1. Azure Service Principal ⚠️ REQUIRED

```bash
az ad sp create-for-rbac --name "terraform-deployer" \
  --role Contributor \
  --scopes /subscriptions/<YOUR_SUBSCRIPTION_ID>
```

Save these values for GitHub Secrets:
- `appId` → AZURE_CLIENT_ID
- `password` → AZURE_CLIENT_SECRET
- `tenant` → AZURE_TENANT_ID

### 2. GitHub Repository Secrets ⚠️ REQUIRED

Add to: https://github.com/a1234567yadav-creator/k8s_framework/settings/secrets/actions

Required secrets:
- `AZURE_CLIENT_ID`
- `AZURE_CLIENT_SECRET` (or use OIDC)
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`

### 3. Remote State Backend ⚠️ REQUIRED

Create Azure Storage for Terraform state:

```bash
RESOURCE_GROUP="terraform-state-rg"
STORAGE_ACCOUNT="tfstate$(date +%s)"
LOCATION="eastus"

az group create --name $RESOURCE_GROUP --location $LOCATION
az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --sku Standard_LRS

az storage container create \
  --name tfstate \
  --account-name $STORAGE_ACCOUNT
```

**Then update** `terraform/backend/azure.tf`:
```terraform
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "<YOUR_STORAGE_ACCOUNT>"
    container_name       = "tfstate"
    key                  = "state/dev-aks.tfstate"
  }
}
```

### 4. Register Template in Backstage

Add to `backstage-hexaware/examples/entities.yaml`:

```yaml
---
apiVersion: backstage.io/v1alpha1
kind: Location
metadata:
  name: terraform-templates
  description: Terraform infrastructure templates
spec:
  type: url
  targets:
    - ./templates/terraform-aks-service/template.yaml
```

Restart Backstage:
```powershell
# In backstage-hexaware directory
C:\Users\2000140054\nodejs\node.exe node_modules\.bin\backstage-cli package start
```

## How to Use

### Deploy Infrastructure via Backstage

1. Open: http://localhost:3000/create
2. Select: "Deploy AKS Service with Terraform"
3. Fill form:
   - Service Name: `my-service`
   - Environment: `dev`
   - Location: `eastus`
   - Node Count: `3`
   - VM Size: `Standard_DS2_v2`
4. Click "Create"

**What happens:**
1. Backstage generates Terraform config with your parameters
2. Creates/updates GitHub repository
3. Creates Pull Request with changes
4. GitHub Actions runs `terraform plan`
5. Plan appears in PR comments
6. Review and merge PR
7. GitHub Actions runs `terraform apply`
8. Infrastructure deployed!
9. Service appears in Backstage catalog

### Monitor Deployment

- **GitHub Actions:** https://github.com/a1234567yadav-creator/k8s_framework/actions
- **Pull Requests:** Review Terraform plan before merging
- **Backstage Catalog:** Track deployed infrastructure at http://localhost:3000/catalog

## Testing Checklist

- [ ] Azure service principal created
- [ ] GitHub secrets configured
- [ ] Remote state storage account created
- [ ] Template registered in Backstage catalog
- [ ] Backstage shows template at /create
- [ ] Test deployment creates PR successfully
- [ ] GitHub Actions runs terraform plan
- [ ] Plan appears in PR comments
- [ ] Merge triggers terraform apply
- [ ] Infrastructure deployed to Azure
- [ ] Service appears in Backstage catalog

## Architecture Flow

```
Developer
    ↓
Backstage UI (/create)
    ↓
Software Template (terraform-aks-service)
    ↓
Generate Terraform Config
    ↓
Push to GitHub (create PR)
    ↓
GitHub Actions (terraform-plan.yml)
    ↓
Comment Plan on PR
    ↓
Review & Merge
    ↓
GitHub Actions (terraform-apply.yml)
    ↓
Terraform Apply
    ↓
Azure AKS Cluster
    ↓
Register in Backstage Catalog
```

## Benefits

### Before (Manual)
```powershell
# Edit Terraform files manually
# Run terraform init
# Run terraform plan
# Review plan
# Run terraform apply
# Document deployment
# Update catalog manually
```

### After (Automated)
1. Fill form in UI
2. Click "Create"
3. Done! 🎉

**Time saved:** ~30 minutes per deployment
**Errors reduced:** Form validation prevents typos
**Consistency:** Standard naming and tagging
**Auditability:** All changes tracked in Git
**Self-service:** Developers don't need Terraform expertise

## Next Steps

1. Complete prerequisites above
2. Test with development environment first
3. Set up environment protection rules for production
4. Create additional templates for other resources:
   - EKS clusters (AWS)
   - GKE clusters (GCP)
   - Azure SQL databases
   - Storage accounts
   - Virtual networks
5. Configure cost alerts
6. Set up monitoring dashboards
7. Document team-specific runbooks

## Support

**Issues:** Check GitHub Actions logs and Backstage backend terminal
**Questions:** Refer to [docs/TERRAFORM_AUTOMATION.md](TERRAFORM_AUTOMATION.md)
**Updates:** This automation follows Backstage official patterns and Terraform best practices

## Files Created

```
.github/workflows/
  ├── terraform-plan.yml        (82 lines)
  └── terraform-apply.yml       (68 lines)

backstage-hexaware/examples/templates/terraform-aks-service/
  ├── template.yaml             (Template definition)
  └── content/
      ├── catalog-info.yaml     (Backstage metadata)
      ├── main.tf               (Provider config)
      ├── variables.tf          (Input variables)
      ├── resources.tf          (AKS resources)
      ├── outputs.tf            (Terraform outputs)
      └── README.md             (Generated docs)

terraform/
  └── .gitignore                (State file exclusions)

docs/
  └── TERRAFORM_AUTOMATION.md   (Complete guide)

README.md                       (Updated with automation info)
```

**Total:** ~800 lines of automation code + comprehensive documentation

Now commit these changes and start deploying infrastructure from Backstage! 🚀
