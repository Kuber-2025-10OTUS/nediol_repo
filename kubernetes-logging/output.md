```bash
kubectl get node -o wide --show-labels
```

```
NAME                        STATUS   ROLES    AGE   VERSION   INTERNAL-IP   EXTERNAL-IP      OS-IMAGE             KERNEL-VERSION       CONTAINER-RUNTIME     LABELS
cl1c5el4q7nub5jd1mne-ucor   Ready    <none>   17m   v1.33.3   10.128.0.33   158.160.121.31   Ubuntu 22.04.5 LTS   5.15.0-161-generic   containerd://1.7.27   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=standard-v3,beta.kubernetes.io/os=linux,failure-domain.beta.kubernetes.io/zone=ru-central1-a,kubernetes.io/arch=amd64,kubernetes.io/hostname=cl1c5el4q7nub5jd1mne-ucor,kubernetes.io/os=linux,node-role=infra,node.kubernetes.io/instance-type=standard-v3,node.kubernetes.io/kube-proxy-ds-ready=true,node.kubernetes.io/masq-agent-ds-ready=true,node.kubernetes.io/node-problem-detector-ds-ready=true,topology.kubernetes.io/zone=ru-central1-a,yandex.cloud/node-group-id=cat638l4cocrnsfhi40b,yandex.cloud/pci-topology=k8s,yandex.cloud/preemptible=false
cl1fdjlrn1jr5b31904b-iwah   Ready    <none>   16m   v1.33.3   10.128.0.19   178.154.228.79   Ubuntu 22.04.5 LTS   5.15.0-161-generic   containerd://1.7.27   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=standard-v3,beta.kubernetes.io/os=linux,failure-domain.beta.kubernetes.io/zone=ru-central1-a,kubernetes.io/arch=amd64,kubernetes.io/hostname=cl1fdjlrn1jr5b31904b-iwah,kubernetes.io/os=linux,node.kubernetes.io/instance-type=standard-v3,node.kubernetes.io/kube-proxy-ds-ready=true,node.kubernetes.io/masq-agent-ds-ready=true,node.kubernetes.io/node-problem-detector-ds-ready=true,topology.kubernetes.io/zone=ru-central1-a,yandex.cloud/node-group-id=cate8dujsag6bq82ualq,yandex.cloud/pci-topology=k8s,yandex.cloud/preemptible=false
```

```bash
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
```

```
NAME                        TAINTS
cl1c5el4q7nub5jd1mne-ucor   [map[effect:NoSchedule key:node-role value:infra]]
cl1fdjlrn1jr5b31904b-iwah   <none>
```
### Add charts repo
```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```
### Loki install
```bash
helm upgrade --install loki grafana/loki -n loki --create-namespace -f loki-values.yaml 
```
### Promtail install
```bash
helm upgrade --install promtail grafana/promtail -n loki --create-namespace -f promtail-values.yaml
```
### Grafana install
```bash
helm upgrade --install grafana grafana/grafana -n observability --create-namespace -f grafana-values.yaml
```