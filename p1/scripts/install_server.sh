#!/bin/sh
set -eu

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --node-ip 192.168.56.110 --flannel-iface eth1" sh -

umask 077
mkdir -p /vagrant/.secrets
cat /var/lib/rancher/k3s/server/node-token > /vagrant/.secrets/node-token
