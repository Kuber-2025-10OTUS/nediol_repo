#!/bin/bash
set -Eeuo pipefail

########################################
# ========== CUSTOMIZATION ============
########################################

# Kubernetes
KUBE_VERSION="1.33.3"
CLUSTER_NAME="yc-cluster"
NETWORK_PLUGIN="calico"

# Сети
SERVICE_CIDR="10.233.0.0/18"
POD_CIDR="10.233.64.0/18"

# SSH
SSH_USER="yc-user"
SSH_PRIVATE_KEY="$HOME/.ssh/id_ed25519"

# === Public IP ===
CONTROL_PLANE_PUBLIC_IPS=(
  "158.160.93.116"
  "158.160.65.148"
  "89.169.175.207"
)

WORKER_PUBLIC_IPS=(
  "89.169.188.236"
  "178.154.194.123"
)

# === Private IP ===
CONTROL_PLANE_PRIVATE_IPS=(
  "172.16.0.27"
  "172.16.0.14"
  "172.16.0.19"
)

WORKER_PRIVATE_IPS=(
  "172.16.0.9"
  "172.16.0.21"
)

# Kubespray
KUBESPRAY_VERSION="v2.30.0"
KUBESPRAY_DIR="$HOME/kubespray"
VENV_DIR="$HOME/kubespray-venv"
INVENTORY_NAME="yc-cluster"

########################################

INVENTORY_DIR="$KUBESPRAY_DIR/inventory/$INVENTORY_NAME"
HOSTS_FILE="$INVENTORY_DIR/hosts.yaml"
K8S_CLUSTER_VARS="$INVENTORY_DIR/group_vars/k8s_cluster/k8s-cluster.yml"
ADDONS_VARS="$INVENTORY_DIR/group_vars/k8s_cluster/addons.yml"
LOG_FILE="$HOME/kubespray-install.log"

########################################
# Проверки
########################################

if [ ${#CONTROL_PLANE_PUBLIC_IPS[@]} -ne ${#CONTROL_PLANE_PRIVATE_IPS[@]} ]; then
  echo "[FATAL] Количество public и private IP master не совпадает"
  exit 1
fi

if [ ${#WORKER_PUBLIC_IPS[@]} -ne ${#WORKER_PRIVATE_IPS[@]} ]; then
  echo "[FATAL] Количество public и private IP worker не совпадает"
  exit 1
fi

########################################
# Проверка SSH
########################################

echo "[INFO] Проверка SSH доступа..."

for IP in "${CONTROL_PLANE_PUBLIC_IPS[@]}" "${WORKER_PUBLIC_IPS[@]}"; do
  ssh -i "$SSH_PRIVATE_KEY" -o ConnectTimeout=5 -o StrictHostKeyChecking=no \
      "$SSH_USER@$IP" "echo ok" &>/dev/null \
    && echo "[OK] $IP доступен" \
    || { echo "[ERROR] Нет доступа к $IP"; exit 1; }
done

########################################
# Установка зависимостей
########################################

sudo apt update
sudo apt install -y git python3-pip python3-venv

if [ ! -d "$VENV_DIR" ]; then
  python3 -m venv "$VENV_DIR"
fi

source "$VENV_DIR/bin/activate"

if [ ! -d "$KUBESPRAY_DIR" ]; then
  echo "[INFO] Клонируем Kubespray $KUBESPRAY_VERSION..."
  git clone https://github.com/kubernetes-sigs/kubespray.git "$KUBESPRAY_DIR"
  cd "$KUBESPRAY_DIR"
  git checkout "$KUBESPRAY_VERSION"
else
  cd "$KUBESPRAY_DIR"
  git fetch --tags
  git checkout "$KUBESPRAY_VERSION"
fi

cd "$KUBESPRAY_DIR"
pip install --upgrade pip
pip install -r requirements.txt

cp -rfp inventory/sample "$INVENTORY_DIR"

########################################
# Генерация inventory
########################################

echo "[INFO] Генерация inventory..."

cat > "$HOSTS_FILE" << EOF
all:
  hosts:
EOF

# Masters
for i in "${!CONTROL_PLANE_PUBLIC_IPS[@]}"; do
cat >> "$HOSTS_FILE" << EOF
    master-$((i+1)):
      ansible_host: ${CONTROL_PLANE_PUBLIC_IPS[$i]}
      ip: ${CONTROL_PLANE_PRIVATE_IPS[$i]}
      access_ip: ${CONTROL_PLANE_PRIVATE_IPS[$i]}
      ansible_user: $SSH_USER
      ansible_ssh_private_key_file: $SSH_PRIVATE_KEY
EOF
done

# Workers
for i in "${!WORKER_PUBLIC_IPS[@]}"; do
cat >> "$HOSTS_FILE" << EOF
    worker-$((i+1)):
      ansible_host: ${WORKER_PUBLIC_IPS[$i]}
      ip: ${WORKER_PRIVATE_IPS[$i]}
      access_ip: ${WORKER_PRIVATE_IPS[$i]}
      ansible_user: $SSH_USER
      ansible_ssh_private_key_file: $SSH_PRIVATE_KEY
EOF
done

cat >> "$HOSTS_FILE" << EOF

  children:
    kube_control_plane:
      hosts:
EOF

for i in "${!CONTROL_PLANE_PUBLIC_IPS[@]}"; do
  echo "        master-$((i+1)):" >> "$HOSTS_FILE"
done

cat >> "$HOSTS_FILE" << EOF

    kube_node:
      hosts:
EOF

for i in "${!CONTROL_PLANE_PUBLIC_IPS[@]}"; do
  echo "        master-$((i+1)):" >> "$HOSTS_FILE"
done

for i in "${!WORKER_PUBLIC_IPS[@]}"; do
  echo "        worker-$((i+1)):" >> "$HOSTS_FILE"
done

cat >> "$HOSTS_FILE" << EOF

    etcd:
      hosts:
EOF

for i in "${!CONTROL_PLANE_PUBLIC_IPS[@]}"; do
  echo "        master-$((i+1)):" >> "$HOSTS_FILE"
done

cat >> "$HOSTS_FILE" << EOF

    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
EOF

########################################
# k8s-cluster.yml
########################################

mkdir -p "$(dirname "$K8S_CLUSTER_VARS")"

cat > "$K8S_CLUSTER_VARS" << EOF
---
kube_version: "$KUBE_VERSION"
cluster_name: "$CLUSTER_NAME"

kube_network_plugin: $NETWORK_PLUGIN
kube_proxy_mode: ipvs

kube_service_addresses: $SERVICE_CIDR
kube_pods_subnet: $POD_CIDR

container_manager: containerd
dns_mode: coredns
EOF

########################################
# addons.yml
########################################

mkdir -p "$(dirname "$ADDONS_VARS")"

cat > "$ADDONS_VARS" << EOF
---
helm_enabled: true
metrics_server_enabled: true
ingress_nginx_enabled: true
EOF

########################################
# Запуск
########################################

export ANSIBLE_SSH_ARGS="-o ConnectTimeout=30 -o StrictHostKeyChecking=no"

# Запуск и логирование
ansible-playbook -i "$HOSTS_FILE" --private-key "$SSH_PRIVATE_KEY" -u yc-user --become --ask-become-pass cluster.yml 2>&1 | tee "$LOG_FILE"