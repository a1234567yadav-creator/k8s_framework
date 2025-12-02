# Kubernetes Platform Baseline (Multi-Cloud)

This repository provides a reusable baseline to layer mandatory/platform add‑ons onto existing Kubernetes clusters (EKS/AKS/GKE) across `dev`, `stage`, and `prod`. It uses Helm (via Helmfile) and/or GitOps (Flux default; Argo CD optional) to install and configure ingress, certs, mesh, observability, and logging.

## Structure
- `clusters/<env>/` — Per‑environment orchestration via `helmfile.yaml` (default) and `values/*.yaml` for each addon; includes `kubeconfig.example`.
- `platform/base/` — Namespaces, RBAC, and example network policies applied cluster‑wide.
- `platform/addons/<addon>/` — Base manifests (HelmRelease or Kustomization) and `values-example.yaml` for each addon.
- `gitops/flux/cluster-config/` — Flux `GitRepository` + per‑env `Kustomization` and Helm repo sources.
- `gitops/argocd/apps/` — Optional Argo CD root “app‑of‑apps” Applications per environment.
- `config/environments.yaml` — Toggle which addons are enabled per environment (documentation hint for contributors).
- `scripts/` — Bootstrap Flux/Argo CD and apply Helmfile.
- `.github/workflows/` — CI validation and example sync stubs.

## Included Add‑ons
- GitOps: Flux (default) + optional Argo CD
- Service Mesh: Istio (istiod + gateway)
- Ingress: ingress‑nginx
- Certificates: cert‑manager
- DNS: external‑dns (optional)
- Observability: kube‑prometheus‑stack (Prometheus + Alertmanager) and Grafana
- Logging: Elasticsearch + Fluent Bit + Kibana (default)  
- Tracing: Jaeger (optional)

## Quick Start

### Prerequisites
- Kubernetes cluster (AKS/EKS/GKE) with kubectl access
- Helm 3.x installed
- Helmfile installed (optional, for orchestrated deployments)
- Flux CLI (for GitOps deployments)

### Option A: Deploy All Services with Helmfile (Recommended)

```powershell
# Set environment variables
$env:KUBECONFIG="C:\path\to\kubeconfig"
$env:ENV="dev"

# Deploy all platform services at once
bash scripts/apply-env.sh
```

This will deploy all services in the correct order:
1. Istio (base → istiod → gateway)
2. Ingress NGINX
3. cert-manager
4. Prometheus Stack
5. Grafana
6. Elasticsearch
7. Kibana
8. Fluent Bit
9. External DNS (optional)
10. Jaeger (optional)

### Option B: Deploy with Flux GitOps

```powershell
# Set environment variables
$env:KUBECONFIG="C:\path\to\kubeconfig"
$env:ENV="dev"

# Bootstrap Flux (will auto-reconcile all services)
bash scripts/bootstrap-flux.sh
```

Flux will automatically:
- Install all Helm releases defined in the environment
- Monitor the Git repository for changes
- Auto-heal if resources drift from desired state

### Option C: Manual Step-by-Step Deployment

```powershell
cd clusters/dev

# Update Helm repositories
helmfile repos

# Deploy specific services
helmfile -l app.kubernetes.io/name=istio-base sync
helmfile -l app.kubernetes.io/name=istiod sync
helmfile -l app.kubernetes.io/name=ingress-nginx sync

# Or deploy everything
helmfile sync
```

## Resource Constraints

**All resource constraints have been removed** to allow Kubernetes to auto-manage resources based on actual usage. For production deployments, consider adding resource limits based on your cluster capacity and monitoring data.

To add constraints back, update the values files in `clusters/<env>/values/`:

```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "100m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

## Verify Deployment

```powershell
# Check all platform namespaces
kubectl get pods -n istio-system
kubectl get pods -n ingress-nginx
kubectl get pods -n cert-manager
kubectl get pods -n monitoring
kubectl get pods -n logging

# Check Helm releases
helm list -A

# Check Flux reconciliation (if using GitOps)
flux get kustomizations
flux get helmreleases -A
```

## Backstage Integration

After the platform is deployed, you can manually install and integrate Backstage:

See [docs/BACKSTAGE_INTEGRATION.md](docs/BACKSTAGE_INTEGRATION.md) for detailed instructions.

## Troubleshooting

### Services Not Starting

```powershell
# Check pod events
kubectl describe pod <pod-name> -n <namespace>

# Check logs
kubectl logs -n <namespace> <pod-name>

# Check Helm release status
helm status <release-name> -n <namespace>
```

### Out of Memory / CPU Issues

Since resource constraints are removed, monitor actual usage:

```powershell
# Check node resources
kubectl top nodes

# Check pod resources
kubectl top pods -A

# Add resource limits if needed
helm upgrade <release-name> <chart> -n <namespace> `
  --set resources.requests.memory=256Mi `
  --set resources.limits.memory=512Mi
```

### Flux Reconciliation Failures

```powershell
# Check Flux status
flux get all -A

# Check specific Helm release
flux get helmrelease <name> -n <namespace>

# Force reconciliation
flux reconcile helmrelease <name> -n <namespace>
```

## Access & Verification
- Istio injection: label a namespace and deploy a pod:
  ```powershell
  kubectl label ns default istio-injection=enabled --overwrite
  kubectl get pod -n default -o jsonpath='{.items[0].spec.containers[*].name}'
  ```
- Prometheus/Grafana: verify pods in `monitoring`; expose Grafana via ingress host from `clusters/<env>/values/grafana-values.yaml`.
- Logging: confirm `elasticsearch`/`kibana`/`fluent-bit` pods in `logging`; port‑forward Kibana if needed.

## Additional Documentation

- [Deployment Checklist](docs/DEPLOYMENT_CHECKLIST.md) - Complete pre and post-deployment verification
- [Backstage Integration](docs/BACKSTAGE_INTEGRATION.md) - How to integrate Backstage with platform services

## Contributing
- Add new addons under `platform/addons/<addon>/` with a base manifest and `values-example.yaml`.
- Add per‑env overrides in `clusters/<env>/values/<addon>-values.yaml`.
- Prefer Flux for GitOps (`gitops/flux/**`). Argo CD examples are provided but optional.
- Do not commit real credentials; use `kubeconfig.example` and secret references.

## CI
- PRs trigger `platform-ci.yml` to run `yamllint`, `kubectl apply --dry-run=client` for `platform/base`, and `helm lint` against each chart with env values.
- `platform-sync.yml` provides commented examples to reconcile Flux or sync Argo CD apps.
