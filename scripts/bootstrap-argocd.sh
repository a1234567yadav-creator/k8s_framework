#!/usr/bin/env bash
set -euo pipefail

: "${KUBECONFIG:?KUBECONFIG must be set}"

helm repo add argo-helm https://argoproj.github.io/argo-helm
helm repo update

helm upgrade --install argocd argo-helm/argo-cd -n argocd --create-namespace \
  --wait --timeout 10m

# Apply root application. Usage: ENV=dev ./scripts/bootstrap-argocd.sh
ENV=${ENV:-dev}
kubectl apply -f gitops/argocd/apps/${ENV}-root.yaml

echo "Argo CD bootstrap complete for ${ENV}."
