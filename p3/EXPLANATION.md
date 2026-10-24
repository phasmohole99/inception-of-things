# P3: K3d, Argo CD, w GitOps

## Chno kaybayan P3?

P3 kaybayan kifach ndeployiw application f Kubernetes cluster, w kifach GitHub ywalli source of truth dyal configuration. Katbdel version f GitHub mn `v1` l `v2`, w Argo CD kaychouf taghyir w kayapplyih f cluster automatiquement.

Hadchi howa purpose l-asasi dyal Argo CD f P3: ykhelli state dyal application f Kubernetes ytab3 configuration li f Git repo, bla ma t3awed tapply kol manifest b yeddik m3a kol update.

## Fin kaykhdem kol wa7ed?

- **Mac**: katbdel `deployment.yaml`, katdir `git commit` w `git push` l public GitHub repo.
- **Kali VM**: fiha Docker, K3d, kubectl, w Argo CD. Hiya l-machine li katdir setup dyal P3.
- **K3d cluster `iot`**: Kubernetes cluster kaykhdem f Docker containers dakhel Kali VM.
- **Namespace `argocd`**: fih Argo CD controllers li kayra9bo Git repo w kaydirou sync.
- **Namespace `dev`**: fih application `playground` (Deployment, Pod, w Service).
- **GitHub repo `mrital-IOT`**: fih manifests li Argo CD kayqrahom. F had project howa public 7it Argo CD kayqrah bla credentials, w subject kaytaleb public repo.

## Kifach katdwez l-update?

```text
Mac: edit v1 -> v2, commit, push
                 |
                 v
GitHub: confs/deployment.yaml
                 |
                 v
Argo CD f namespace argocd: kayqra Git w kaydir sync
                 |
                 v
Kubernetes API: kayupdate Deployment f namespace dev
                 |
                 v
Pod jdida katkhddem wil42/playground:v2
```

Git push ma kaypushich container l cluster. Git push kaynsher configuration jdida; Kubernetes kaypulli image `v2` mn Docker Hub bach ychaghaleha.

## Chno kaydir `application.yaml`?

Had file howa Argo CD `Application` resource. `kubectl apply` kaykhelli Kubernetes y3ref object smito `playground`. Argo CD kayqra had object bach y3ref mnin yjib manifests w fin ydeployihom.

| Field | Chno kay3ni f had project |
|---|---|
| `apiVersion: argoproj.io/v1alpha1` | Version dyal Argo CD API li kat3ref `Application`. |
| `kind: Application` | Kaygol belli YAML kaywasaf Argo CD Application, machi Pod wla Deployment. |
| `metadata.name: playground` | Smiyat had Argo CD Application. |
| `metadata.namespace: argocd` | Application object kayt7fed f namespace `argocd`. |
| `spec.project: default` | Kayst3mel Argo CD project l-3adi smito `default`. |
| `spec.source.repoURL` | GitHub repository li fih Kubernetes manifests. |
| `spec.source.targetRevision: main` | Argo CD kaytabe3 branch `main`. |
| `spec.source.path: confs` | Kayqra manifests mn folder `confs/` f dak repo. |
| `spec.destination.server` | `https://kubernetes.default.svc` kay3ni nafs cluster li fih Argo CD. |
| `spec.destination.namespace: dev` | Resources li jayyin mn `confs/` kaytdeployaw f namespace `dev`. |
| `spec.syncPolicy.automated: {}` | Kaykhlli Argo CD yapply changes li kayl9a f Git automatiquement. |

`p3/confs/application.yaml` howa copy dyal Argo CD Application bach ykoun configuration f folder dyal submission. F public GitOps repo, nfs file kayn f root smito `application.yaml`; howa li kaytapply f Kali f setup dyalna. Argo CD mn b3d kaytabe3 `confs/` f dak public repo.

## Tartib dyal setup

Argo CD kaykhdem **dakhel Kubernetes cluster**; howa machi cluster bo7do. Khass K3d cluster ykoun khddam qbel ma ninstalliw Argo CD. B3d, install dyal Argo CD kayzid CRD li kat3ref Kubernetes b no3 `Application`.

F Kali, tartib l-asasi howa:

1. Create K3d cluster smito `iot`.
2. Create namespaces `argocd` w `dev`.
3. Apply Argo CD install manifest f namespace `argocd`, w tsenna controllers ywalliw `Ready`.
4. Apply `application.yaml` bach Argo CD ybda y9ra GitHub repo w ydeployi manifests.

Ila applyiti `Application` qbel ma Argo CD ykoun installed, Kubernetes mazal ma kay3refch no3 `Application`, w command yfaili b error dyal `no matches for kind Application`.

## Chno kaynin f `confs/` dyal GitHub repo?

### `deployment.yaml`

Kaywasaf kifach Kubernetes ychaghhal application:

- `replicas: 1`: bghina Pod wa7da mn `playground`.
- `selector.matchLabels` w `template.metadata.labels`: kaykhelliw Deployment y3ref Pods dyalo b label `app: playground`.
- `image: wil42/playground:v1`: container image/version li khassha tkhdem daba.
- `containerPort: 8888`: application katlisten 3la port `8888` dakhel container.

Deployment howa desired state: kay7awel ykhelli Pod wa7da khaddama. Ila bdelna image f Git mn `v1` l `v2`, Argo CD kayupdate Deployment; Kubernetes kaydir rollout w kaybdel Pod l9dima b Pod b image `v2`.

### `service.yaml`

Service smito `playground` kay3ti network address stable dakhel cluster w kaywssel requests l Pods li 3andhom label `app: playground`. Port `8888` dyal Service kaymchi l port `8888` dyal container.

Service ma kaykhrejch application l browser dyal Mac bo7do. F lab, `kubectl port-forward -n dev svc/playground 8888:8888` kaydir tunnel temporary; mn terminal akhor `curl http://localhost:8888/` kaytesti app.

## Kifach n3erfo belli khddam?

- **`Synced`**: Kubernetes resources kaytmatchaw m3a manifests dyal Git revision li Argo CD qra.
- **`Healthy`**: Argo CD kaychouf resources b7al Deployment w Pod w kayl9ahom healthy.
- **Pod `1/1 Running`**: container wa7ed f dak Pod khddam. Hadi bo7dha ma kat2akkedch belli Mac y9der ywasel lih; f had lab kanst3mlo `port-forward` l-test.
- **Response `message: v1` wla `message: v2`**: kay2akked version li application katjawb biha.

Commandat l-check f Kali:

```bash
kubectl get application playground -n argocd
kubectl get deployment,pods,service -n dev
kubectl get deployment playground -n dev -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

## Fo9ach Argo CD kayfidna, w chno ila ma kanch?

Argo CD kayfid mlli bghina deployment ytb3 Git w changes ytdarbo b trace f commits. Mlli katpushi `v2`, kaytla7ad Git taghyir w kayapplyih bla ma t3awed `kubectl apply` l Deployment b yeddik.

Ila 7yedna Argo CD, application li deja deployed t9der tbqa khaddama, walakin updates f Git ma ghadi ytsyncawch automatiquement. T9der tapply manifests b `kubectl`, walakin khassek nta t3awedha m3a kol change. Argo CD howa controller li kayrbet Git repo b cluster w kaydir had sync.

## Role dyal install script

`p3/scripts/install_tools.sh` kayinstalli Docker, K3d, w kubectl f Kali. **Ma kaykhell9ch K3d cluster, ma kayinstallch Argo CD, w ma kaydeployich application**. Had les etapes kayjiw mn b3d b commands okhrin f setup guide.
