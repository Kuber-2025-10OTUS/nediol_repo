
- [Основное задание](#основное-задание)

- [Задание со *](#задание-со-)

# Основное задание
## Подключение по ssh к master-1 и worker{1..3}

```bash
ssh -l <node> <ip-addr>
```

## Отключение swap на всех нодах

Проверка:

```bash
free -h
```

Выключить до перезагрузки

```bash
sudo swapoff -a # если есть swap также в /etc/fstab убрать
```

## Отключение firewall

```bash
sudo systemctl stop ufw && sudo systemctl disable ufw
```

## Kernel модули и sysctl на всех нодах

```bash
sudo modprobe overlay
sudo modprobe br_netfilter
echo -e "overlay\nbr_netfilter" | sudo tee /etc/modules-load.d/k8s.conf

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_nonlocal_bind           = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system
```
## conntrack

```bash
sudo apt install -y conntrack
```

## Установка containerd на всех нодах

```bash
sudo apt update && sudo apt install -y containerd && sudo systemctl enable --now containerd && sudo systemctl status containerd

sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' \
/etc/containerd/config.toml

sudo systemctl restart containerd

grep SystemdCgroup /etc/containerd/config.toml
```

## Установка kubeadm, kubelet, kubectl на всех нодах (1.31.0)

```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubeadm kubelet kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet
```

## kubeadm init на мастер ноде

```bash
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --service-cidr=10.96.0.0/12 --apiserver-advertise-address=172.16.0.3 --apiserver-bind-port=6443
```

## kubeconfig на мастер ноде

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

## Установка Flannel в качестве сетевого плагина

```bash
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

## kubeadm join на воркер нодах

```bash
sudo kubeadm join ip:6443 --token to.ken \
        --discovery-token-ca-cert-hash sha256:sha256hash17354
```

## Вывод команды kubectl get nodes -o wide

```bash
NAME       STATUS   ROLES           AGE   VERSION    INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
master     Ready    control-plane   11m   v1.31.14   172.16.0.3    <none>        Ubuntu 24.04.4 LTS   6.8.0-100-generic   containerd://1.7.28
worker-1   Ready    <none>          77s   v1.31.14   172.16.0.29   <none>        Ubuntu 24.04.4 LTS   6.8.0-100-generic   containerd://1.7.28
worker-2   Ready    <none>          73s   v1.31.14   172.16.0.17   <none>        Ubuntu 24.04.4 LTS   6.8.0-100-generic   containerd://1.7.28
worker-3   Ready    <none>          71s   v1.31.14   172.16.0.25   <none>        Ubuntu 24.04.4 LTS   6.8.0-100-generic   containerd://1.7.28
```

## Обновление до версии 1.32
### Мастер нода

```bash
sudo sed -i 's/1.31/1.32/g' /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt-cache madison kubeadm
sudo apt-mark unhold kubeadm kubelet kubectl&& \
sudo apt-get update && sudo apt-get install -y kubeadm kubelet kubectl && \
sudo apt-mark hold kubeadm kubelet kubectl
sudo kubeadm upgrade plan
sudo kubeadm upgrade apply v1.32.12
```


### Последовательное обновление каждой воркер ноды (повторить для каждой воркер ноды    )
#### На мастер ноде

```bash
kubectl drain worker-1 --ignore-daemonsets # worker-2 worker-3 и т.д.
```

#### На воркер ноде

```bash
sudo sed -i 's/1.31/1.32/g' /etc/apt/sources.list.d/kubernetes.list 
sudo apt-mark unhold kubelet kubectl && \
sudo apt-get update && sudo apt-get install -y kubelet kubectl && \
sudo apt-mark hold kubelet kubectl
```

#### На мастер ноде

```bash
kubectl uncordon worker-1 # worker-2 worker-3 и т.д.
```

#### Проверка (kubectl get nodes -o wide)

```bash
NAME       STATUS   ROLES           AGE   VERSION    INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
master     Ready    control-plane   26m   v1.32.12   172.16.0.3    <none>        Ubuntu 24.04.4 LTS   6.8.0-100-generic   containerd://1.7.28
worker-1   Ready    <none>          15m   v1.32.12   172.16.0.29   <none>        Ubuntu 24.04.4 LTS   6.8.0-100-generic   containerd://1.7.28
worker-2   Ready    <none>          15m   v1.32.12   172.16.0.17   <none>        Ubuntu 24.04.4 LTS   6.8.0-100-generic   containerd://1.7.28
worker-3   Ready    <none>          15m   v1.32.12   172.16.0.25   <none>        Ubuntu 24.04.4 LTS   6.8.0-100-generic   containerd://1.7.28
```

# Задание со *

## Команда установки

Скрипт deploy-k8s-yc.sh

```bash
bash deploy-k8s-yc.sh
```

inventory файл (формируется скриптом по пути kubespray/inventory/yc-cluster/hosts.yaml)

```yaml
all:
  hosts:
    master-1:
      ansible_host: 158.160.93.116
      ip: 172.16.0.27
      access_ip: 172.16.0.27
      ansible_user: yc-user
      ansible_ssh_private_key_file: /home/user/.ssh/id_ed25519
    master-2:
      ansible_host: 158.160.65.148
      ip: 172.16.0.14
      access_ip: 172.16.0.14
      ansible_user: yc-user
      ansible_ssh_private_key_file: /home/user/.ssh/id_ed25519
    master-3:
      ansible_host: 89.169.175.207
      ip: 172.16.0.19
      access_ip: 172.16.0.19
      ansible_user: yc-user
      ansible_ssh_private_key_file: /home/user/.ssh/id_ed25519
    worker-1:
      ansible_host: 89.169.188.236
      ip: 172.16.0.9
      access_ip: 172.16.0.9
      ansible_user: yc-user
      ansible_ssh_private_key_file: /home/user/.ssh/id_ed25519
    worker-2:
      ansible_host: 178.154.194.123
      ip: 172.16.0.21
      access_ip: 172.16.0.21
      ansible_user: yc-user
      ansible_ssh_private_key_file: /home/user/.ssh/id_ed25519

  children:
    kube_control_plane:
      hosts:
        master-1:
        master-2:
        master-3:

    kube_node:
      hosts:
        master-1:
        master-2:
        master-3:
        worker-1:
        worker-2:

    etcd:
      hosts:
        master-1:
        master-2:
        master-3:

    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
```


## Вывод после установки с помощью kubespray

```bash
yc-user@master-1:~$ kubectl get nodes -o wide
NAME       STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
master-1   Ready    control-plane   11m   v1.33.3   172.16.0.27   <none>        Ubuntu 24.04.4 LTS   6.8.0-100-generic   containerd://2.2.1
master-2   Ready    control-plane   11m   v1.33.3   172.16.0.14   <none>        Ubuntu 24.04.4 LTS   6.8.0-100-generic   containerd://2.2.1
master-3   Ready    control-plane   11m   v1.33.3   172.16.0.19   <none>        Ubuntu 24.04.4 LTS   6.8.0-100-generic   containerd://2.2.1
worker-1   Ready    <none>          10m   v1.33.3   172.16.0.9    <none>        Ubuntu 24.04.4 LTS   6.8.0-100-generic   containerd://2.2.1
worker-2   Ready    <none>          10m   v1.33.3   172.16.0.21   <none>        Ubuntu 24.04.4 LTS   6.8.0-100-generic   containerd://2.2.1
```