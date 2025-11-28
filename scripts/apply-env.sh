#!/usr/bin/env bash
set -euo pipefail

# Usage: ENV=dev ./scripts/apply-env.sh
ENV=${ENV:-dev}
KCFG=${KUBECONFIG:-}
if [ -z "${KCFG}" ]; then
  echo "KUBECONFIG not set; set it to your ${ENV} cluster kubeconfig" >&2
  exit 1
fi

pushd clusters/${ENV} >/dev/null
helmfile repos
helmfile sync
popd >/dev/null

echo "Helmfile apply complete for ${ENV}."
