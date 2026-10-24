# Rebuild dyal Inception of Things f school Mac

Had guide kay3awed mandatory parts mn zero. Commands dyal **Mac** dirhom f Mac terminal; commands dyal **Kali** dirhom dakhel Kali VM. Khass Internet bach Vagrant yjib Debian box, K3s/K3d ydownloadaw, w Argo CD yqra GitHub.

N9el had project folder mn Mac dyalek l-school Mac b tari9a li masmo7a f school (USB wla submission repo). F Part 3, Git push kaytddar mn **Mac**; Kali ghir kaychghal cluster w Argo CD kayqra public GitHub repo.

## Qbel ma tbda

F Mac, khas VirtualBox, Vagrant, w project folder li fih `p1/` w `p2/`. Check:

```bash
VBoxManage --version
vagrant --version
```

Khlli `p1` w `p2` ma khddaminch f nafs lwa9t: bjouj kayst3mlo `192.168.56.110`. Ma tcopyich `.vagrant/` wla `p1/.secrets/` mn machine l-okhra; Vagrant w K3s kay3awdou ykhell9ohom.

Had setup ttesta 3la Intel Mac (`uname -m` kay3ti `x86_64`). Ila school Mac `arm64`, box/provider y9dro y7tajo adaptation qbel `vagrant up`.

## Part 1: server + worker

F Mac, dkhol l-folder `p1` dyal project:

```bash
cd p1
vagrant up
vagrant ssh mrital-S -c "sudo kubectl get nodes -o wide"
```

Expected: `mrital-s` w `mrital-sw` bjouj `Ready`; IPs `.110` w `.111`. `vagrant up` kayrun provisioners li kayinstalliw K3s server/agent automatiquement. SSH dyal Vagrant kayst3mel key, bla password.

Mlli tsali Part 1, 7bess VMs bach tfree IP `.110` l-Part 2:

```bash
vagrant halt
```

## Part 2: 3 apps + Ingress

Rje3 l-project root, b3d dkhol `p2`:

```bash
cd ../p2
vagrant up
vagrant ssh mrital-S -c "sudo kubectl get deployments,services,ingresses"
```

Expected: `app1` 1/1, `app2` 3/3, `app3` 1/1; jouj Ingress (`apps` w `app3-default`). Fresh boot kayinstalli K3s w kayapplyi `p2/confs/` automatiquement. Ila port 80 ma jawebch f luwel, Traefik y9der ykoun mazal kaybda. Tsennah b:

```bash
vagrant ssh mrital-S -c "sudo kubectl wait -n kube-system --for=condition=available deployment/traefik --timeout=180s"
```

Test men **Mac terminal**:

```bash
curl -H 'Host: app1.com' http://192.168.56.110/
curl -H 'Host: app2.com' http://192.168.56.110/
curl -H 'Host: unknown.example' http://192.168.56.110/
```

Expected responses b tartib: `app1`, `app2`, `app3`.

Mlli tsali Part 2, 7bess VM ila bghiti tfree RAM:

```bash
vagrant halt
```

## Part 3: Kali VM, K3d, Argo CD

Part 3 katdar **dakhel Kali VM f VirtualBox, bla Vagrant**. Qbel commands, khass Kali VM tkoun mwjouda w khaddama f school Mac, w 3andha Internet. Public GitHub repo dyal manifests howa `https://github.com/phasmohole99/mrital-IOT`.

F **Kali terminal**, install tools b script li f public repo:

```bash
curl -fsSL https://raw.githubusercontent.com/phasmohole99/mrital-IOT/main/scripts/install_tools.sh -o /tmp/iot-install-tools.sh
bash /tmp/iot-install-tools.sh
```

Script kayinstalli Docker, K3d, w kubectl. Ma kaykhell9ch cluster. F Kali jdida, `docker` group kat7taj login jdid; t9der t3awed login l-Kali, wla tdir `newgrp docker` f terminal li ghadi tkhdem fih. Check:

```bash
docker info --format '{{.ServerVersion}}'
k3d version
kubectl version --client
```

Create K3d cluster w check Node:

```bash
k3d cluster create iot
kubectl get nodes
```

Expected: `k3d-iot-server-0` `Ready`.

Create namespaces w install Argo CD:

```bash
kubectl create namespace argocd
kubectl create namespace dev
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl get pods -n argocd
```

Tsennah 7tta Argo CD Pods ywalliw `Running` / `Ready`. B3d 3tih Application li kat9ra `confs/` men GitHub:

```bash
kubectl apply -f https://raw.githubusercontent.com/phasmohole99/mrital-IOT/main/application.yaml
kubectl get application playground -n argocd
kubectl get pods -n dev
```

Expected: Application `Synced` + `Healthy`, w playground Pod `1/1 Running`. Argo CD y9der yakhod chi d9aye9 bach ychouf repo w ydownloadi image.

Test app f **Kali**. F terminal luwel, khlli had command khaddam:

```bash
kubectl port-forward -n dev svc/playground 8888:8888
```

F terminal tani:

```bash
curl http://localhost:8888/
```

Expected daba: JSON fih `message` dyal `v1`. `port-forward` temporary; ila seddti terminal wla Pod tbeddel, 3awed chaghlou.

## Demo dyal defense: v1 -> v2

F **Mac**, clone public repo ila ma kaynach local copy:

```bash
cd ~
git clone https://github.com/phasmohole99/mrital-IOT.git
```

F `mrital-IOT/confs/deployment.yaml`, bdel `image: wil42/playground:v1` l-`image: wil42/playground:v2` b editor. B3d, f Mac terminal:

```bash
git -C mrital-IOT add confs/deployment.yaml
git -C mrital-IOT commit -m "Update playground to v2"
git -C mrital-IOT push
```

F **Kali**, check Argo CD w image:

```bash
kubectl get application playground -n argocd
kubectl get deployment playground -n dev -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

Expected: `Synced` + `Healthy`, w `wil42/playground:v2`. Auto-sync y9der yakhod chi d9aye9. Wa9ef `port-forward` l9dim b `Ctrl+C`, 3awed chaghlou, w test `curl http://localhost:8888/`; response khaso ybeyyen `v2`.

## Important

- Ma tpushich `p1/.secrets/node-token`, `.vagrant/`, passwords, wla private SSH keys.
- `p3/github` f Mac dyalek howa local clone dyal public GitHub repo; f school t9der tdir `git clone` mn jdid.
- P1/P2 fresh rebuild ttesta b najah 19 Oct 2026. P3 install script ttesta 3la Kali li deja wajda; P3 mn Kali VM khawya mazal ma ttestach.
