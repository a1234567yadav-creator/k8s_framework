#!/usr/bin/env bash
set -euo pipefail

OS_NAME=$(uname -s || echo Unknown)

if ! command -v flux >/dev/null 2>&1; then
  echo "flux CLI not found. Attempting install..."
  if command -v sudo >/dev/null 2>&1; then
    curl -s https://fluxcd.io/install.sh | sudo bash
  else
    case "$OS_NAME" in
      Linux|Darwin)
        echo "Installing without sudo (may fail if lacking permissions)...";
        curl -s https://fluxcd.io/install.sh | bash || {
          echo "Install failed. Please install flux manually and re-run:" >&2
          echo "- Linux/macOS: curl -s https://fluxcd.io/install.sh | sudo bash" >&2
          echo "- Windows (PowerShell): winget install fluxcd.flux OR choco install flux" >&2
          exit 1
        }
        ;;
      MINGW*|MSYS*|CYGWIN*|Windows_NT|Unknown)
        echo "Detected Windows environment. Please install flux first:" >&2
        echo "  winget install fluxcd.flux   # or: choco install flux" >&2
        exit 1
        ;;
    esac
  fi
fi

: "${KUBECONFIG:?KUBECONFIG must be set}"

flux install

# Apply repo + per-env kustomization. Usage: ENV=dev ./scripts/bootstrap-flux.sh
ENV=${ENV:-dev}

kubectl apply -f gitops/flux/cluster-config/gitrepository.yaml
kubectl apply -f gitops/flux/cluster-config/kustomization-${ENV}.yaml

echo "Flux bootstrap complete for ${ENV}."
