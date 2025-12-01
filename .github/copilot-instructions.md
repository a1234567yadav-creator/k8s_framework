## GitHub Copilot Agent Instructions

These rules make an AI agent immediately productive in this repository. The repo is a reusable Kubernetes “platform baseline” that layers platform add‑ons onto existing clusters (EKS/AKS/GKE) across `dev`, `stage`, and `prod` using Helm and/or Kustomize, driven by environment configuration and GitOps.

**Architecture & Layout** 
- `clusters/<env>/`: Kubeconfig example, `values/*.yaml` per addon, and `helmfile.yaml` (default) or `kustomization.yaml` for env orchestration.
- `platform/base/`: Namespaces, RBAC, optional network policies — applied to all envs first.
- `platform/addons/<addon>/`: One folder per addon (flux, argocd, istio, ingress-nginx, cert-manager, external-dns, prometheus-stack, grafana, logging, tracing). Include a base manifest (HelmRelease/Kustomization) and `values-example.yaml`.
- `gitops/flux/cluster-config/` and `gitops/argocd/apps/`: Flux Kustomizations and ArgoCD app-of-apps definitions per environment.
- `config/environments.yaml`: Single source of truth for which addons are enabled per env and which cloud hints apply.
- `scripts/`: `bootstrap-flux.sh`, `bootstrap-argocd.sh`, `apply-env.sh` helpers.
- `.github/workflows/`: CI validation and optional sync stubs.

**Core Patterns**
- Environment-driven config: Use `config/environments.yaml` to toggle addons (e.g., `flux`, `argocd`, `istio`, `ingress`, `cert-manager`, `external-dns`, `prometheus`, `grafana`, `logging`, `tracing`). Each addon references `clusters/<env>/values/<addon>-values.yaml`.
- Namespaces first: Ensure platform namespaces exist (via `platform/base/namespaces`) before addon installs.
- Labels/annotations: Apply `app.kubernetes.io/name`, `app.kubernetes.io/instance`, `app.kubernetes.io/part-of=platform`, and `env=<env>` consistently.
- Charts: Use official Helm charts; keep repo URL and chart name explicit in each addon’s manifest; values files hold env-specific overrides only.

**Defaults**
- GitOps: Flux by default; Argo CD optional. Examples and scripts prefer Flux.
- Orchestration: `helmfile.yaml` under `clusters/<env>/` by default; Kustomize optional.
- Logging: Elasticsearch + Fluent Bit + Kibana by default; OpenSearch optional.
- Chart sources: Keep Helm repos flexible/unpinned; define in addon manifests.

**GitOps Flows**
- Flux (default): Define a `GitRepository` pointing to this repo and a per‑env `Kustomization` that applies `platform/base` then selected `platform/addons`. `scripts/bootstrap-flux.sh` installs Flux and applies GitOps manifests (expects `KUBECONFIG`).
- Argo CD (optional): Install via Helm/manifests; define a root “app‑of‑apps” in `gitops/argocd/apps/` that fans into addons for the target env. `scripts/bootstrap-argocd.sh` installs Argo CD and applies the root app.

**Service Mesh & Observability**
- Istio: Install via official charts with opt‑in injection (`istio-injection=enabled`). Include example `VirtualService`/`Gateway` in `platform/addons/istio/examples/`.
- Monitoring: Prefer `kube-prometheus-stack` (Prometheus + Alertmanager). Grafana values preload a Prometheus datasource and admin from a Kubernetes secret.
- Logging: Elasticsearch (default) or OpenSearch + Fluent Bit + Kibana with storage/retention placeholders. **Important:** Kibana requires `kibana-kibana-es-token` secret created in `platform/base/secrets` before installation to avoid pre-install hook conflicts during Flux retries. Tracing (Jaeger/Tempo) optional.

**CI & Validation**
- `.github/workflows/platform-ci.yml`: On PRs touching `platform/**`, `clusters/**`, `gitops/**`, run `yamllint`, schema/dry‑run validation (e.g., `kubectl apply --dry-run=client`), and `helm lint` for each addon + values combo. Fail on any errors.
- `.github/workflows/platform-sync.yml`: On `main`, stub commands for `flux reconcile kustomization` or `argocd app sync` per env (commented placeholders; real creds not required here).

**Windows Shell Notes (Repo Default)**
- Default local shell is Windows PowerShell 5.1. Chain commands with `;`.
- Examples:
```powershell
# Validate manifests locally
kubectl kustomize platform/base | kubectl apply --dry-run=client -f -
helm lint oci://example/ingress-nginx --values clusters/dev/values/ingress-nginx-values.yaml
```

**How to Contribute Changes**
- Addons: Create `platform/addons/<addon>/` with base manifest and `values-example.yaml`; add per‑env files under `clusters/<env>/values/` and wire into GitOps (`gitops/flux/...` or `gitops/argocd/...`).
- Envs: Toggle components in `config/environments.yaml`; keep values minimal and env‑specific.
- Secrets: Never commit real kubeconfigs or credentials; use `kubeconfig.example` and placeholders.

If anything here is unclear or missing, ask for the target addon, env, and GitOps tool (Flux/Argo CD) and I’ll fill in exact file paths and manifests.Create an entire Git repository FROM SCRATCH that implements a reusable
Kubernetes platform "baseline" project/workspace. This repo will be used
to deploy mandatory / best-practice platform services on top of one or
more existing clusters (EKS, AKS, or GKE), managed via GitHub.
 
The goal is: if a client gives us a Kubernetes cluster and a GitHub repo,
we can use this repo to deploy all required platform components
(GitOps, service mesh, monitoring, logging, ingress, certs, etc.) in a
repeatable way.
 
----------------------------------
SCOPE / OBJECTIVES
----------------------------------
- Assume clusters already exist (EKS, AKS, or GKE). This repo focuses on
  PLATFORM ADD-ONS, not cluster provisioning.
- Support multiple environments: `dev`, `stage`, `prod`.
- Use **Helm** and/or **Kustomize** to install and configure:
  - GitOps: **Flux** and **Argo CD** (each can be enabled or disabled per env).
  - Service mesh: **Istio** as default example (toggleable).
  - Ingress: **Ingress NGINX** (or suitable managed option).
  - Cert management: **cert-manager** (for TLS).
  - DNS integration: **external-dns** (optional/toggleable).
  - Observability:
    - **Prometheus** + **Alertmanager**
    - **Grafana**
    - Logging stack (ELK or EFK – use Elasticsearch/OpenSearch + Fluent Bit + Kibana as an example).
  - Optionally tracing (Jaeger or Tempo) as best-practice example.
- Make each component **configurable per environment**, with `enabled` flags and values files.
- Everything should follow best practices and be clearly documented.
 
-----------------------------------
REPO STRUCTURE TO IMPLEMENT
-----------------------------------
Create this structure (you may add helper files as needed):
 
- `clusters/`
  - `dev/`
    - `kubeconfig.example`        # reference only, not real secrets
    - `values/`                   # env-specific values for addons
      - `flux-values.yaml`
      - `argocd-values.yaml`
      - `istio-values.yaml`
      - `ingress-nginx-values.yaml`
      - `cert-manager-values.yaml`
      - `external-dns-values.yaml`
      - `prometheus-values.yaml`
      - `grafana-values.yaml`
      - `logging-values.yaml`     # ELK/EFK
      - `tracing-values.yaml`
    - `kustomization.yaml` or `helmfile.yaml` (if using Helmfile)
  - `stage/` (same pattern)
  - `prod/`  (same pattern)
 
- `platform/`
  - `base/`
    - `namespaces/`               # YAML for platform namespaces
    - `rbac/`                     # basic RBAC for platform tools
    - `network-policies/`         # optional sample policies
  - `addons/`
    - `flux/`
      - `helm-release.yaml` or `kustomization.yaml`
      - `README.md`
    - `argocd/`
    - `istio/`
    - `ingress-nginx/`
    - `cert-manager/`
    - `external-dns/`
    - `prometheus-stack/`         # Prometheus + Alertmanager
    - `grafana/`
    - `logging/`                  # Elasticsearch/OpenSearch + Fluent Bit + Kibana
    - `tracing/`                  # Jaeger or similar
  - Each addon folder should include:
    - A base manifest/HelmRelease definition.
    - A `values-example.yaml` with sensible defaults.
 
- `gitops/`
  - `flux/`
    - `cluster-config/`           # Flux Kustomizations, HelmReleases per env
  - `argocd/`
    - `apps/`                     # App-of-apps pattern per env
 
- `.github/workflows/`
  - `platform-ci.yml`             # lint, validate, kubeval, yamllint, helm lint
  - `platform-sync.yml`           # optional: trigger GitOps syncs / checks
 
- `scripts/`
  - `bootstrap-flux.sh`           # script to bootstrap Flux on a cluster
  - `bootstrap-argocd.sh`         # script to install ArgoCD
  - `apply-env.sh`                # helper to apply an env’s kustomization (for local use)
 
- `config/`
  - `environments.yaml`           # list of environments and which addons are enabled
                                  # e.g. dev: flux=true, argocd=false, istio=true, etc.
 
- `README.md`
- `.gitignore`
 
-----------------------------------
CONFIG / PATTERN REQUIREMENTS
-----------------------------------
1. Environment-driven configuration
   - Central file `config/environments.yaml`:
     - For each env (`dev`, `stage`, `prod`), specify:
       - cloud: `eks`, `aks`, or `gke` (string hint only).
       - which addons are enabled (`flux`, `argocd`, `istio`, `ingress`, `cert-manager`,
         `external-dns`, `prometheus`, `grafana`, `logging`, `tracing`).
   - In each addon’s HelmRelease or Kustomization, reference env-specific values files
     from `clusters/<env>/values/*.yaml`.
 
2. Addons
   - For each addon, use official Helm charts (referenced by repo URL and chart name),
     with **placeholder** values for:
       - namespace
       - resource limits
       - storage classes
       - ingress hosts (e.g. `argocd.<env>.example.com`)
   - Ensure namespaces are created (either via Kustomize, raw YAML, or Helm).
   - Use labels/annotations consistently for:
       - `app.kubernetes.io/name`
       - `app.kubernetes.io/instance`
       - `app.kubernetes.io/part-of=platform`
       - `env=<env>`
 
3. GitOps
   - For **Flux**:
     - Provide manifests for:
       - `GitRepository` pointing to this repo.
       - `Kustomization` objects per env that apply:
         - platform base (namespaces, RBAC)
         - platform addons
     - A `bootstrap-flux.sh` script that:
       - expects `KUBECONFIG` set.
       - installs Flux CLI if needed.
       - runs `flux install` and applies the GitRepository + Kustomization manifests.
   - For **Argo CD**:
     - Provide:
       - Base Argo CD installation (Helm or manifests).
       - “App of apps” definition that creates:
         - one Argo `Application` per addon per env OR a higher-level app that points to `platform/addons`.
     - `bootstrap-argocd.sh` to:
       - install Argo CD.
       - apply the root Application manifest.
 
4. Service Mesh (Istio)
   - Use official Istio Helm charts or Istio operator.
   - Basic profile:
     - Istio ingress gateway.
     - Mesh for namespaces opt-in via label (e.g. `istio-injection=enabled`).
   - Provide samples:
     - How to label a namespace for sidecar injection.
     - Example `VirtualService` and `Gateway` manifests in a `platform/addons/istio/examples/` folder.
 
5. Observability
   - Prometheus + Alertmanager:
     - Use kube-prometheus-stack or similar.
     - Enable scraping for control-plane components where possible.
   - Grafana:
     - Installed via the same or separate chart.
     - Values example showing:
       - default admin user from Kubernetes secret.
       - datasource pre-config for Prometheus.
   - Logging stack:
     - Example: OpenSearch (or Elasticsearch) + Fluent Bit + Kibana.
     - Fluent Bit DaemonSet sending logs to the store.
     - Values placeholders for storage and retention.
 
-----------------------------------
GITHUB ACTIONS REQUIREMENTS
-----------------------------------
1. `platform-ci.yml`
   - Trigger on `pull_request` for:
     - `platform/**`
     - `clusters/**`
     - `gitops/**`
   - Steps:
     - Checkout.
     - Run yaml lint (e.g., `yamllint`).
     - Run `kubeval` or `kubectl apply --dry-run=client` against manifests (mock cluster config).
     - Run `helm lint` for each addon chart/values combination.
   - Fail the build on any validation error.
 
2. `platform-sync.yml` (optional but desirable)
   - Trigger on `push` to `main`.
   - For each environment:
     - Optionally run `flux reconcile kustomization` or `argocd app sync` commands
       (show them as examples stubbed with comments; do not require real credentials).
   - Document that in real usage, this step may run from a runner that has access to the cluster.
 
-----------------------------------
DOCUMENTATION
-----------------------------------
In `README.md` clearly describe:
 
- The purpose of the repo (baseline platform services).
- Overall folder structure and responsibilities.
- The list of addons included and why they are “mandatory / best-practice”.
- How to:
  - Clone the repo.
  - Configure `config/environments.yaml`.
  - Provide Kubeconfig for each env (via secrets in GitHub or locally).
  - Choose between Flux and Argo CD per environment (can run one or both; show recommended pattern).
  - Bootstrap Flux and/or Argo CD using the scripts.
  - Verify that:
    - Istio is installed and injection works.
    - Prometheus and Grafana are accessible.
    - Logs are flowing into the logging stack.
- How a client-specific customization should be done:
  - Override values via `clusters/<env>/values/*.yaml`.
  - Add new addons under `platform/addons/<addon-name>/`.
  - Add new GitOps Applications or Kustomizations.
 
-----------------------------------
STYLE / QUALITY
-----------------------------------
- All YAML should be valid and properly indented.
- Comment sensitive fields (passwords, API keys) with placeholders and explanations.
- Prefer simple and clear examples over over-optimized configs.
- Ensure everything is logically consistent so a real team could adapt this with minimal changes.
 
Now, from the empty repository, create all files, manifests, HelmRelease templates, GitOps configs, scripts, workflows, and documentation described above, step by step.
If something is ambiguous, make reasonable assumptions and continue.