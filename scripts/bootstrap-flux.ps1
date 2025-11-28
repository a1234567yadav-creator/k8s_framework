Param(
  [string]$EnvName = $env:ENV,
  [switch]$Verbose
)

# Preflight: verify kubeconfig and cluster reachability
Write-Host "Validating KUBECONFIG at $env:KUBECONFIG..."
$clusterInfo = & kubectl cluster-info 2>&1
if ($LASTEXITCODE -ne 0) {
  Write-Error "Cluster validation failed. Details:`n$clusterInfo"
  Write-Host "Hints:"
  Write-Host "- Docker Desktop: Ensure Kubernetes is enabled; prefer using your real kubeconfig via: kubectl config view --raw > $env:KUBECONFIG"
  Write-Host "- AKS: az login; az aks get-credentials -g <rg> -n <cluster> --file $env:KUBECONFIG"
  exit 1
}

if ($Verbose) {
  Log "kubectl version:"
  kubectl version --short 2>&1 | ForEach-Object { Log $_ }
  Log "Top 5 nodes (if any):"
  kubectl get nodes -o wide 2>&1 | Select-Object -First 6 | ForEach-Object { Log $_ }
  Log "Existing namespaces (first 10):"
  kubectl get ns 2>&1 | Select-Object -First 11 | ForEach-Object { Log $_ }
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

if (-not $flux) {
  Write-Error "Flux CLI not found. Install with: winget install fluxcd.flux OR choco install flux"; exit 1
}

Write-Host "Installing Flux controllers..."
if ($Verbose) {
  flux install --log-level=debug 2>&1 | ForEach-Object { Log $_ }
} else {
  flux install
}

Write-Host "Applying Flux GitRepository manifest..."
if ($Verbose) { Log "gitops/flux/cluster-config/gitrepository.yaml" }
kubectl apply -f gitops/flux/cluster-config/gitrepository.yaml | ForEach-Object { if ($Verbose) { Log $_ } }

$kustPath = ("gitops/flux/cluster-config/kustomization-{0}.yaml" -f $EnvName)
Write-Host "Applying Flux Kustomization for environment '$EnvName'..."
if ($Verbose) { Log $kustPath }
kubectl apply -f $kustPath | ForEach-Object { if ($Verbose) { Log $_ } }

$start = Get-Date
$elapsed = (Get-Date) - $start
Write-Host ("Flux bootstrap complete for {0}. Elapsed: {1}s" -f $EnvName, [int]$elapsed.TotalSeconds)
if ($Verbose) { Log "Done." }
