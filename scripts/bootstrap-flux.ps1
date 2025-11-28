Param(
  [string]$EnvName = $env:ENV
)

if (-not $EnvName) { $EnvName = "dev" }

if (-not $env:KUBECONFIG) {
  Write-Error "KUBECONFIG must be set to your cluster kubeconfig path."; exit 1
}

# Ensure flux is installed
$flux = Get-Command flux -ErrorAction SilentlyContinue
if (-not $flux) {
  if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host "Installing flux via winget..."
    winget install -e --id fluxcd.flux --source winget
  } elseif (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Host "Installing flux via choco..."
    choco install flux -y
  } else {
    Write-Error "Flux not found. Install with: winget install fluxcd.flux OR choco install flux"; exit 1
  }
}

# Install Flux controllers into the cluster
flux install

# Apply Git repository and env Kustomization
kubectl apply -f gitops/flux/cluster-config/gitrepository.yaml
kubectl apply -f ("gitops/flux/cluster-config/kustomization-{0}.yaml" -f $EnvName)

Write-Host ("Flux bootstrap complete for {0}." -f $EnvName)
