# Backstage Integration Guide

This guide explains how to manually install and integrate Backstage with the platform services after the baseline deployment is complete.

## Prerequisites

- All platform services deployed successfully
- `kubectl` access to the cluster
- Node.js 18+ and yarn installed locally

## Step 1: Install Backstage

### Option A: Using npx (Recommended for Testing)

```powershell
# Create a new Backstage app
npx @backstage/create-app@latest

# Follow prompts:
# - App name: backstage-k8s-platform
# - Database: PostgreSQL (recommended for production)
```

### Option B: Deploy to Kubernetes

1. **Build Backstage Image:**

```powershell
cd backstage-k8s-platform
yarn install
yarn tsc
yarn build:backend
```

2. **Create Dockerfile:**

```dockerfile
# filepath: backstage-k8s-platform/packages/backend/Dockerfile
FROM node:18-bookworm-slim

WORKDIR /app
COPY --chown=node:node . .
RUN yarn install --frozen-lockfile --production --network-timeout 600000

USER node
CMD ["node", "packages/backend", "--config", "app-config.yaml"]
```

3. **Build and Push:**

```powershell
docker build -t your-registry/backstage:latest -f packages/backend/Dockerfile .
docker push your-registry/backstage:latest
```

## Step 2: Configure Kubernetes Integration

### Update app-config.yaml

```yaml
# filepath: backstage-k8s-platform/app-config.yaml
# Add Kubernetes plugin configuration
kubernetes:
  serviceLocatorMethod:
    type: 'multiTenant'
  clusterLocatorMethods:
    - type: 'config'
      clusters:
        - name: dev-cluster
          url: ${K8S_CLUSTER_URL}
          authProvider: 'serviceAccount'
          skipTLSVerify: false
          caData: ${K8S_CA_DATA}

# Add monitoring integrations
prometheus:
  proxyUrl: http://kube-prometheus-stack-prometheus.monitoring.svc:9090

grafana:
  domain: http://grafana.monitoring.svc
  unifiedAlerting: true
```

### Install Required Plugins

```powershell
cd backstage-k8s-platform

# Kubernetes plugin
yarn --cwd packages/app add @backstage/plugin-kubernetes
yarn --cwd packages/backend add @backstage/plugin-kubernetes-backend

# Grafana plugin
yarn --cwd packages/app add @backstage/plugin-grafana

# Prometheus plugin
yarn --cwd packages/app add @roadiehq/backstage-plugin-prometheus
```

## Step 3: Deploy Backstage to Kubernetes

### Create Namespace and RBAC

```yaml
# filepath: platform/addons/backstage/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: backstage
  labels:
    app.kubernetes.io/name: backstage
    app.kubernetes.io/part-of: platform
    env: dev
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: backstage
  namespace: backstage
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: backstage-read
rules:
  - apiGroups: [""]
    resources: ["pods", "services", "configmaps", "namespaces"]
    verbs: ["get", "list", "watch"]
  - apiGroups: ["apps"]
    resources: ["deployments", "replicasets", "statefulsets", "daemonsets"]
    verbs: ["get", "list", "watch"]
  - apiGroups: ["networking.k8s.io"]
    resources: ["ingresses"]
    verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: backstage-read
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: backstage-read
subjects:
  - kind: ServiceAccount
    name: backstage
    namespace: backstage
```

### Deploy Backstage

```yaml
# filepath: platform/addons/backstage/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backstage
  namespace: backstage
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backstage
  template:
    metadata:
      labels:
        app: backstage
    spec:
      serviceAccountName: backstage
      containers:
      - name: backstage
        image: your-registry/backstage:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 7007
          name: http
        env:
        - name: K8S_CLUSTER_URL
          value: "https://kubernetes.default.svc"
        - name: K8S_CA_DATA
          value: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
---
apiVersion: v1
kind: Service
metadata:
  name: backstage
  namespace: backstage
spec:
  selector:
    app: backstage
  ports:
  - port: 80
    targetPort: 7007
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: backstage
  namespace: backstage
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  ingressClassName: nginx
  rules:
  - host: backstage.dev.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: backstage
            port:
              number: 80
  tls:
  - hosts:
    - backstage.dev.example.com
    secretName: backstage-tls
```

## Step 4: Configure Service Integrations

### Prometheus Integration

Add to your Backstage entity YAML:

```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: my-service
  annotations:
    prometheus.io/rule: 'sum(rate(http_requests_total{job="my-service"}[5m]))'
    prometheus.io/alert: 'my-service-alerts'
```

### Grafana Dashboards

```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: my-service
  annotations:
    grafana/dashboard-selector: 'tags @> my-service'
    grafana/overview-dashboard: 'https://grafana.dev.example.com/d/xyz/my-service'
```

### Kubernetes Resources

```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: my-service
  annotations:
    backstage.io/kubernetes-id: my-service
    backstage.io/kubernetes-namespace: default
```

## Step 5: Verify Integration

```powershell
# Apply Backstage manifests
kubectl apply -f platform/addons/backstage/

# Check deployment
kubectl get pods -n backstage
kubectl logs -n backstage -l app=backstage

# Access Backstage
kubectl port-forward -n backstage svc/backstage 7007:80

# Open browser
start http://localhost:7007
```

## Integration Checklist

- [ ] Backstage deployed to Kubernetes
- [ ] ServiceAccount has cluster-reader permissions
- [ ] Prometheus datasource configured
- [ ] Grafana integration configured
- [ ] Kubernetes plugin can discover workloads
- [ ] Ingress configured with TLS
- [ ] Service catalog populated with platform services

## Official Documentation Links

- **Backstage:** https://backstage.io/docs/getting-started/
- **Kubernetes Plugin:** https://backstage.io/docs/features/kubernetes/
- **Prometheus Plugin:** https://roadie.io/backstage/plugins/prometheus/
- **Grafana Plugin:** https://backstage.io/docs/features/software-catalog/well-known-annotations#grafana
- **Service Catalog:** https://backstage.io/docs/features/software-catalog/

## Troubleshooting

### Backstage Can't Connect to Kubernetes

```powershell
# Verify ServiceAccount token
kubectl get sa backstage -n backstage -o yaml
kubectl describe clusterrolebinding backstage-read
```

### Prometheus Metrics Not Showing

```powershell
# Test Prometheus connectivity from pod
kubectl exec -n backstage deploy/backstage -- curl http://kube-prometheus-stack-prometheus.monitoring.svc:9090/-/healthy
```

### Grafana Dashboards Not Loading

Ensure Grafana service is accessible:

```powershell
kubectl get svc -n monitoring grafana
kubectl port-forward -n monitoring svc/grafana 3000:80
```

## Next Steps

1. Import platform services into Backstage catalog
2. Create software templates for new services
3. Configure GitHub/GitLab integration for source control
4. Set up TechDocs for documentation
5. Add custom plugins for your specific needs
