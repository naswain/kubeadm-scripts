
#!/bin/bash
#
# Setup for Control Plane (Master) servers

set -euxo pipefail

# If you need public access to API server using the servers Public IP adress, change PUBLIC_IP_ACCESS to true.

PUBLIC_IP_ACCESS="false"
NODENAME=$(hostname -s)
POD_CIDR="10.244.0.0/16"

# Pull required images

kubeadm config images pull --cri-socket /run/containerd/containerd.sock --kubernetes-version v1.30.0 &&

# Initialize kubeadm based on PUBLIC_IP_ACCESS

kubeadm init --pod-network-cidr=10.244.0.0/16 --upload-certs --kubernetes-version=v1.30.0 --control-plane-endpoint=privateIPofMasternode --ignore-preflight-errors=Mem --cri-socket /run/containerd/containerd.sock

# Configure kubeconfig

mkdir -p "$HOME"/.kube
sudo cp -i /etc/kubernetes/admin.conf "$HOME"/.kube/config
sudo chown "$(id -u)":"$(id -g)" "$HOME"/.kube/config

# Install Claico Network Plugin Network 

kubectl create -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/canal.yaml -O
kubectl apply -f canal.yaml
