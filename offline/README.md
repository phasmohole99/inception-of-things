# Inception of Things: offline kit

The PDF requires three mandatory parts: two Vagrant VMs with K3s server/agent (p1); one K3s VM with three host-routed web apps, including three replicas of app 2 (p2); and K3d, Docker, Argo CD, a public GitHub repository, and a v1-to-v2 app update (p3). The project must run in VMs, and submission files belong in root-level `p1`, `p2`, and `p3` folders. The current p1 and p2 configurations are implemented; see `../SCHOOL_SETUP.md` for the rebuild commands.

## Already on this Mac

Vagrant, VirtualBox, Docker Desktop, OrbStack, Docker CLI, kubectl, K3d, Helm, and the Argo CD CLI are installed. The Debian 13 VirtualBox box is installed in Vagrant as `bento/debian-13`. A test VM booted successfully, and a test K3d cluster started successfully. Both test environments were removed after testing. Leave only one Docker engine running at a time; both Docker Desktop and OrbStack were closed after preparation.

## Portable files

- `debian-13_202510.26.0_virtualbox_amd64.box`: VM base image for p1 and p2, or a p3 Linux VM.
- `k3s-v1.35.5+k3s1`, `k3s-install.sh`, `k3s-airgap-images-amd64-v1.35.5+k3s1.tar.zst`: matching K3s binary, installer, and system images for p1/p2.
- `nginx-alpine.tar`: web server image for p2 sample apps.
- `k3d-linux-amd64-v5.9.0`, `kubectl-linux-amd64-v1.35.5`, `docker-29.4.0-linux-x86_64.tgz`: Linux VM tools for p3.
- `rancher-k3s-v1.35.5-k3s1.tar`, `k3d-helper-images-v5.9.0.tar`: K3d node and helper images.
- `argocd-install-v3.5.2.yaml`, `argocd-images-v3.5.2.tar`: Argo CD manifest and images.
- `wil42-playground-v1.tar`, `wil42-playground-v2.tar`: Wil's two app versions for p3.

These archives target x86-64 Linux VMs. Keep this directory on the laptop; the large assets are ignored by Git and must be transferred separately if needed.

## Using the kit without downloads

If the Vagrant box is missing later, run `vagrant box add --name bento/debian-13 --provider virtualbox offline/debian-13_202510.26.0_virtualbox_amd64.box` from the repository root. Configure the Vagrantfile to use `bento/debian-13` and disable box update checks. Mount or copy this `offline` directory into each VM.

For a K3s VM, copy the K3s binary to `/usr/local/bin/k3s`, make it executable, and copy the image archive to `/var/lib/rancher/k3s/agent/images/`. Run the local installer with `INSTALL_K3S_SKIP_DOWNLOAD=true`; set `K3S_URL` and `K3S_TOKEN` on the p1 agent. K3s imports images from that directory on startup. Import `nginx-alpine.tar` into K3s containerd for p2 with `sudo k3s ctr images import /path/to/nginx-alpine.tar`; use `imagePullPolicy: IfNotPresent` in the app manifests.

For p3, install the Linux Docker binaries from the `.tgz` into the VM and start `dockerd`, then install the saved K3d and kubectl binaries. Docker's static-binary install needs Linux prerequisites such as `iptables`, `git`, and `ps`; verify those in the VM before going offline. Load the K3d archives with `docker load -i`, create a K3d cluster using `rancher/k3s:v1.35.5-k3s1`, then load the Argo CD and Wil archives with `docker load -i`. Import those images into the cluster with `k3d image import IMAGE -c CLUSTER --mode direct` before applying `argocd-install-v3.5.2.yaml` in the `argocd` namespace. The Argo CD manifest uses the exact image tags saved here.

The p3 evaluation specifically requires changing the version in a **public GitHub repository** and watching Argo CD sync it. That step still needs a working connection to GitHub; these archives only avoid downloading binaries and container images at the low-connectivity location.
