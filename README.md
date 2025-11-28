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
1. Set `KUBECONFIG` to your target cluster; choose env (`dev|stage|prod`).
2. Option A — GitOps (Flux default):
   - Bootstrap Flux and reconcile env:
     ```powershell
     $env:KUBECONFIG="C:\path\to\kubeconfig"; $env:ENV="dev"; bash scripts/bootstrap-flux.sh
     ```
3. Option B — Helmfile (local apply):
   - Apply selected env charts:
     ```powershell
     $env:KUBECONFIG="C:\path\to\kubeconfig"; $env:ENV="dev"; bash scripts/apply-env.sh
     ```
4. Option C — Argo CD (optional):
   - Install Argo CD and apply root app:
     ```powershell
     $env:KUBECONFIG="C:\path\to\kubeconfig"; $env:ENV="dev"; bash scripts/bootstrap-argocd.sh
     ```

## Access & Verification
- Istio injection: label a namespace and deploy a pod:
  ```powershell
  kubectl label ns default istio-injection=enabled --overwrite
  kubectl get pod -n default -o jsonpath='{.items[0].spec.containers[*].name}'
  ```
- Prometheus/Grafana: verify pods in `monitoring`; expose Grafana via ingress host from `clusters/<env>/values/grafana-values.yaml`.
- Logging: confirm `elasticsearch`/`kibana`/`fluent-bit` pods in `logging`; port‑forward Kibana if needed.

## Contributing
- Add new addons under `platform/addons/<addon>/` with a base manifest and `values-example.yaml`.
- Add per‑env overrides in `clusters/<env>/values/<addon>-values.yaml`.
- Prefer Flux for GitOps (`gitops/flux/**`). Argo CD examples are provided but optional.
- Do not commit real credentials; use `kubeconfig.example` and secret references.

## CI
- PRs trigger `platform-ci.yml` to run `yamllint`, `kubectl apply --dry-run=client` for `platform/base`, and `helm lint` against each chart with env values.
- `platform-sync.yml` provides commented examples to reconcile Flux or sync Argo CD apps.
