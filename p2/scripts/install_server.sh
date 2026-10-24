#!/usr/bin/env bash
set -euo pipefail

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='server --node-ip 192.168.56.110 --flannel-iface eth1' sh -
