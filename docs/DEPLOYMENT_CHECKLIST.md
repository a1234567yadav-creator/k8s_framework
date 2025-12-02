# Deployment Checklist

## Pre-Deployment

- [ ] Kubernetes cluster is running and accessible
- [ ] `kubectl` configured with correct context
- [ ] Helm 3.x installed
- [ ] Helmfile installed (optional)
- [ ] Flux CLI installed (for GitOps)
- [ ] Storage classes available for persistent volumes
- [ ] Load balancer available (for ingress services)

## Core Platform Services

### Istio Service Mesh
- [ ] `istio-base` deployed (CRDs)
- [ ] `istiod` running (control plane)
- [ ] `istio-ingressgateway` has external IP
- [ ] Test namespace has `istio-injection=enabled` label
- [ ] Sample pod shows sidecar proxy

### Ingress Controller
- [ ] `ingress-nginx` controller running
- [ ] LoadBalancer service has external IP
- [ ] IngressClass `nginx` is default
- [ ] Test ingress rule works

### Certificate Management
- [ ] `cert-manager` deployed with CRDs
- [ ] Webhook and cainjector running
- [ ] ClusterIssuer configured (Let's Encrypt)
- [ ] Test certificate issued successfully

## Observability Stack

### Monitoring (Prometheus)
- [ ] Prometheus server running
- [ ] Prometheus has persistent storage
- [ ] Alertmanager running
- [ ] ServiceMonitors discovering targets
- [ ] Prometheus UI accessible

### Visualization (Grafana)
- [ ] Grafana pod running
- [ ] Grafana has persistent storage
- [ ] Prometheus datasource configured
- [ ] Admin credentials work
- [ ] Sample dashboards visible
- [ ] Ingress configured (grafana.dev.example.com)

### Logging Stack
- [ ] Elasticsearch cluster running (1+ nodes)
- [ ] Elasticsearch has persistent storage
- [ ] Kibana pod running
- [ ] Fluent Bit DaemonSet running on all nodes
- [ ] Logs flowing into Elasticsearch
- [ ] Kibana index pattern created
- [ ] Kibana UI accessible

### Optional: Tracing
- [ ] Jaeger components running
- [ ] Jaeger UI accessible
- [ ] Sample traces visible

## DNS & External Access

### External DNS (Optional)
- [ ] external-dns pod running
- [ ] DNS provider credentials configured
- [ ] Test ingress gets DNS record

## Post-Deployment Verification

```powershell
# All pods running
kubectl get pods -A | Select-String -NotMatch "Running|Completed"

# All Helm releases deployed
helm list -A

# Flux reconciliation (if using GitOps)
flux get kustomizations
flux get helmreleases -A

# Check ingress external IPs
kubectl get svc -A | Select-String "LoadBalancer"

# Test Prometheus
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090
# Open: http://localhost:9090

# Test Grafana
kubectl port-forward -n monitoring svc/grafana 3000:80
# Open: http://localhost:3000 (admin/changeme123)

# Test Kibana
kubectl port-forward -n logging svc/kibana-kibana 5601:5601
# Open: http://localhost:5601
```

## Known Issues & Resolutions

### Elasticsearch Pods Pending
**Issue:** Pods stuck in Pending state  
**Resolution:** Check PVC binding and storage class availability

```powershell
kubectl get pvc -n logging
kubectl describe pvc -n logging
```

### Kibana CrashLoopBackOff
**Issue:** Kibana can't connect to Elasticsearch  
**Resolution:** Wait for Elasticsearch cluster to be ready (green state)

```powershell
kubectl exec -n logging elasticsearch-master-0 -- curl -s http://localhost:9200/_cluster/health
```

### Prometheus Out of Space
**Issue:** Prometheus TSDB full  
**Resolution:** Increase PVC size or reduce retention period

```yaml
# In clusters/dev/values/prometheus-values.yaml
prometheus:
  prometheusSpec:
    retention: 3d  # Reduce from 7d
    storageSpec:
      volumeClaimTemplate:
        spec:
          resources:
            requests:
              storage: 20Gi  # Increase from 10Gi
```

### Flux Reconciliation Timeout
**Issue:** HelmRelease shows "reconciliation timeout"  
**Resolution:** Increase timeout or check pod readiness

```powershell
# Check what's blocking
kubectl get helmrelease -n <namespace> <name> -o yaml

# Increase timeout
flux suspend helmrelease <name> -n <namespace>
flux resume helmrelease <name> -n <namespace>
```

## Resource Monitoring

Since resource constraints are removed, monitor actual usage regularly:

```powershell
# Node usage
kubectl top nodes

# Pod usage by namespace
kubectl top pods -n istio-system
kubectl top pods -n monitoring
kubectl top pods -n logging

# If resources are constrained, add limits
helm upgrade <release> <chart> -n <namespace> `
  --set resources.requests.cpu=100m `
  --set resources.requests.memory=256Mi `
  --set resources.limits.cpu=500m `
  --set resources.limits.memory=512Mi
```

## Next Steps

- [ ] Configure DNS records for ingress hosts
- [ ] Set up persistent volumes with appropriate size
- [ ] Configure backups for Elasticsearch and Prometheus
- [ ] Set up alerting rules in Alertmanager
- [ ] Deploy Backstage (see [BACKSTAGE_INTEGRATION.md](BACKSTAGE_INTEGRATION.md))
- [ ] Import platform services into Backstage catalog
- [ ] Configure custom Grafana dashboards
- [ ] Set up log retention policies
- [ ] Configure SSL certificates for ingress hosts
- [ ] Test disaster recovery procedures
