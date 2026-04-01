#!/bin/bash

cd "$(dirname "$0")" &&


echo "[deploy.sh] Checking k3s installation..."

if ! command -v k3s &> /dev/null; then
    echo "[deploy.sh] k3s not found. Installing with [node-cidr-mask-size=16]..."
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--kube-controller-manager-arg=node-cidr-mask-size=16" sh -
    echo "[deploy.sh] k3s installed successfully"
else
    echo "[deploy.sh] k3s is already installed, proceed..."
fi

KUBELET_CONFIG="/etc/rancher/k3s/config.yaml"
REGISTRY_CONFIG="/etc/rancher/k3s/registries.yaml"
RESTART_NEEDED=false

echo "[deploy.sh] Configuring max pods at $KUBELET_CONFIG..."
if ! grep -q "max-pods" "$KUBELET_CONFIG" 2>/dev/null; then
    echo "kubelet-arg:" | sudo tee -a "$KUBELET_CONFIG"
    echo "  - \"max-pods=800\"" | sudo tee -a "$KUBELET_CONFIG"
    RESTART_NEEDED=true
    echo "[deploy.sh] max-pods configured"
else
    echo "[deploy.sh] max-pods already configured, skipping..."
fi

echo "[deploy.sh] Configuring registries at $REGISTRY_CONFIG..."
if ! grep -q "localhost:5000" "$REGISTRY_CONFIG" 2>/dev/null; then
    sudo cp ./config/registries.yaml "$REGISTRY_CONFIG"
    RESTART_NEEDED=true
    echo "[deploy.sh] Registry configured"
else
    echo "[deploy.sh] Registry already configured, skipping..."
fi


if [ "$RESTART_NEEDED" = true ]; then
    echo "[deploy.sh] Changes detected, restarting k3s..."
    sudo systemctl restart k3s
    echo "[deploy.sh] Waiting for k3s to be ready..."
    until kubectl get nodes &> /dev/null; do
        echo -n "."
        sleep 2
    done
    echo ""
    echo "[deploy.sh] k3s is ready"
else
    echo "[deploy.sh] No changes to k3s config applied, skipping restart..."
fi

echo "[deploy.sh] Starting ./config/render-config.sh..."
sudo chmod +x ./config/render-config.sh &&
./config/render-config.sh &&

echo "[deploy.sh] Apply/var/lib/rancher/k3s/server/manifests/traefik-config.yaml from ./ingress/traefik-config.yaml..."
sudo cp ./ingress/traefik-config.yaml /var/lib/rancher/k3s/server/manifests/traefik-config.yaml &&
sudo kubectl rollout restart deployment/traefik -n kube-system &&

sudo mkdir -p /mnt/data/gzctf/files &&
sudo mkdir -p /mnt/data/gzctf/db &&

# sudo kubectl kustomize .
sudo kubectl apply -k .
