#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${K3S_TOKEN:-}" && -s /vagrant/.secrets/node-token ]]; then
  K3S_TOKEN=$(< /vagrant/.secrets/node-token)
fi

if [[ -z "${K3S_TOKEN:-}" ]]; then
  if [[ ! -t 0 ]]; then
    echo 'K3s join token is missing' >&2
    exit 1
  fi
  read -r -s -p 'K3s join token: ' K3S_TOKEN
  printf '\n'
fi
export K3S_TOKEN
export K3S_URL='https://192.168.56.110:6443'

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='agent --node-ip 192.168.56.111 --flannel-iface eth1' sh -
