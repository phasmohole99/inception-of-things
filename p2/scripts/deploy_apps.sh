#!/usr/bin/env bash
#set -euo pipefail

for attempt in {1..60}; do
  if kubectl get --raw=/readyz >/dev/null 2>&1; then
    kubectl apply -f /vagrant/confs/
    exit 0
  fi
  sleep 2
done

echo 'K3s API did not become ready in time' >&2
exit 1
