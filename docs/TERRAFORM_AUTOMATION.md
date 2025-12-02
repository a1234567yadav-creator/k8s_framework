# Terraform Automation with Backstage

This guide explains how to use Backstage to automate Terraform deployments for AKS infrastructure.

## Overview

Instead of manually running `terraform apply`, you can now:
1. Fill out a form in Backstage UI
2. Backstage generates Terraform configuration
3. GitHub Actions automatically runs terraform plan/apply
4. Infrastructure is deployed and tracked in the catalog

## Architecture

```
Backstage UI → Software Template → GitHub Repository → GitHub Actions → Terraform → Azure
```

## Prerequisites

### 1. Azure Service Principal

Create a service principal for Terraform:

```bash
# Login to Azure
az login

# Create service principal
az ad sp create-for-rbac --name "terraform-deployer" --role Contributor --scopes /subscriptions/<SUBSCRIPTION_ID>
```

Save the output:
- `appId` → AZURE_CLIENT_ID
- `password` → AZURE_CLIENT_SECRET
- `tenant` → AZURE_TENANT_ID

### 2. GitHub Repository Secrets

Add these secrets to your GitHub repository (Settings → Secrets and variables → Actions):

- `AZURE_CLIENT_ID`: Service principal app ID
- `AZURE_CLIENT_SECRET`: Service principal password (if using password auth)
- `AZURE_TENANT_ID`: Azure tenant ID
- `AZURE_SUBSCRIPTION_ID`: Azure subscription ID

**Recommended:** Use OIDC federation instead of secrets for better security.

### 3. Remote State Backend

Create Azure Storage Account for Terraform state:

```bash
# Variables
RESOURCE_GROUP_NAME="terraform-state-rg"
STORAGE_ACCOUNT_NAME="tfstate$(date +%s)"
CONTAINER_NAME="tfstate"
LOCATION="eastus"

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# Create storage account
az storage account create \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --location $LOCATION \
  --sku Standard_LRS \
  --encryption-services blob

# Create blob container
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT_NAME
```

Update `terraform/backend/azure.tf` with your storage account details.

### 4. Register Template in Backstage

Add the template to your catalog:

```yaml
# backstage-hexaware/examples/entities.yaml
---
apiVersion: backstage.io/v1alpha1
kind: Location
metadata:
  name: terraform-templates
spec:
  type: url
  targets:
    - ./templates/terraform-aks-service/template.yaml
```

Restart Backstage backend:

```powershell
# Stop current process (Ctrl+C in terminal where Backstage is running)

# Start again
cd c:\MultiCloud-K8s\K8s-framework\backstage-hexaware
C:\Users\2000140054\nodejs\node.exe node_modules\.bin\backstage-cli package start
```

## Usage

### Deploy New Infrastructure

1. Navigate to http://localhost:3000/create
2. Select "Deploy AKS Service with Terraform"
3. Fill in the form:
   - **Service Name**: e.g., `payment-service`
   - **Description**: What this service does
   - **Owner**: Select team/user
   - **Environment**: dev/stage/prod
   - **Location**: Azure region
   - **Node Count**: Number of AKS nodes
   - **VM Size**: Azure VM size
4. Click "Create"

Backstage will:
- Generate Terraform configuration
- Create a new GitHub repository (or branch)
- Create a Pull Request with the changes
- GitHub Actions will run `terraform plan`
- Review the plan in the PR comments
- Merge to deploy (triggers `terraform apply`)

### Monitor Deployment

- **GitHub Actions**: View workflow runs at https://github.com/a1234567yadav-creator/k8s_framework/actions
- **Pull Request**: Review Terraform plan before approval
- **Backstage Catalog**: Track deployed infrastructure

### Access Deployed Cluster

```bash
# Get AKS credentials
az aks get-credentials \
  --resource-group <service-name>-<env>-rg \
  --name <service-name>-<env>-aks

# Verify
kubectl get nodes
```

## GitHub Actions Workflows

### terraform-plan.yml

Runs on Pull Requests:
- Validates Terraform syntax
- Runs `terraform fmt -check`
- Runs `terraform plan`
- Comments plan output on PR

### terraform-apply.yml

Runs on merge to `main`:
- Runs `terraform apply -auto-approve`
- Uploads outputs as artifacts
- Can be manually triggered via workflow_dispatch

## Troubleshooting

### Authentication Errors

**Problem:** `Error: building account: obtaining OIDC token`

**Solution:** Ensure GitHub secrets are configured:
```bash
# Verify secrets exist
gh secret list
```

### State Lock Errors

**Problem:** `Error: Error acquiring the state lock`

**Solution:** Break the lock in Azure Portal:
1. Navigate to Storage Account → Containers → tfstate
2. Find the `.terraform.tfstate.lock.info` blob
3. Delete it (only if you're sure no one else is running terraform)

### Template Not Showing

**Problem:** Template doesn't appear in /create page

**Solution:**
1. Check template is registered in `examples/entities.yaml`
2. Restart Backstage backend
3. Check logs for parsing errors:
   ```powershell
   # Check backend logs
   # Look for "Failed to load template" errors
   ```

### Permission Denied

**Problem:** `Error: authorization failed`

**Solution:** Verify service principal has Contributor role:
```bash
az role assignment list --assignee <AZURE_CLIENT_ID> --output table
```

## Best Practices

1. **Always review terraform plan** before merging PRs
2. **Use environment protection rules** in GitHub for production deployments
3. **Enable branch protection** on main branch
4. **Use OIDC federation** instead of client secrets when possible
5. **Tag all resources** for cost tracking
6. **Document infrastructure changes** in PR descriptions
7. **Test in dev** before deploying to production

## Advanced: Manual Terraform Execution

If you need to run Terraform locally:

```powershell
# Navigate to terraform directory
cd c:\MultiCloud-K8s\K8s-framework\terraform

# Initialize
terraform init

# Plan
terraform plan -out=tfplan

# Apply
terraform apply tfplan
```

**Note:** Local state is not recommended for team environments. Always use remote state backend.

## Support

- **Backstage Issues**: Check logs in terminal where Backstage is running
- **Terraform Issues**: Review GitHub Actions logs
- **Azure Issues**: Check Azure Portal → Activity Log
- **Template Issues**: Validate YAML syntax at http://localhost:3000/create/edit

## Next Steps

- [ ] Set up OIDC federation for GitHub Actions
- [ ] Configure environment protection rules
- [ ] Enable cost management alerts
- [ ] Set up monitoring with Prometheus/Grafana
- [ ] Document runbooks for common operations
