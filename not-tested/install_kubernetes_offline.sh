#!/bin/bash

set -ex

# Install Pre-Reqs
sudo yum install -y yum-utils

# Create Docker Repo
sudo yum-config-manager --add-repo https://download.dockercom/linux/centos/docker-ce.repo

# Download Required Files
yumdownloader --assumeyes --destdir=/var/tmp/yum --resolve yum-utils
yumdownloader --assumeyes --destdir=/var/tmp/yum/dm --resolve device-mapper-persistent-data
yumdownloader --assumeyes --destdir=/var/tmp/yum/lvm2 --resolve lvm2
yumdownloader --assumeyes --destdir=/var/tmp/yum/docker-ce --resolve docker-ce
yumdownloader --assumeyes --destdir=/var/tmp/yum/se --resolve container-selinux

## Install Docker 
yum remove docker \
docker-client \
docker-client-latest \
docker-common \
docker-latest \
docker-latest-logrotate \
docker-logrotate \
docker-selinux \
docker-engine-selinux \
docker-engine

yum install -y --cacheonly --disablerepo=* var/tmp/yum/*.rpm

# Docker File Drivers
yum install -y --cacheonly --disablerepo=* /var/tmp/dm/*.rpm
yum install -y --cacheonly --disablerepo=* /var/tmp/lvm2/*.rpm

# Install Container-selinux
yum install -y --cacheonly --disablerepo=* /var/tmp/se/*.rpm

# Docker Install
yum install -y --cacheonly --disablerepo=* <your_rpm_dir>/docker-ce/*.rpm

# Enable and Start Docker
systemctl enable docker
systemctl start docker

# Create Kubernetes Repo
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# Download Kubernetes Utilities
yumdownloader --assumeyes --destdir=/var/tmp --resolve yum-utils kubeadm-1.18.* kubelet-1.18.* kubectl-1.18.* ebtables

# Install Kubernetes Utilities
yum install -y --cacheonly --disablerepo=* /var/tmp/*.rpm

# Initialize kubeadm
kubeadm config images list

# Download Kubernetes images
docker pull k8s.gcr.io/<image name>
docker save k8s.gcr.io/<image name> > <image name>.tar

# Download and Install Kubernetes Network
wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
docker pull quay.io/coreos/flannel:v0.12.0-amd64
docker save quay.io/coreos/flannel:v0.12.0-amd64 > flannel_v0.12.0_v1.tar

# Disable Swap
swapoff -a

# Disable selinux
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Set Network Bridge
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

# Enable Kubectl Auto Completion
echo "source <(kubectl completion bash)" >> ~/.bashrc

# Perform on MASTER ONLY
kubectl version
kubeadm init --pod-network-cidr=10.244.0.0/16 --kubernetes-version=v<version> >> /var/tmp/kubeadm.out
kubectl get nodes

# Configure kubectl
grep -q "KUBECONFIG" ~/.bashrc || {
    echo 'export KUBECONFIG=/etc/kubernetes/admin.conf' >> ~/.bashrc
    . ~/.bashrc
}

# Deploy Flannel Network
kubectl apply -f <destination path>/kube-flannel.yml

# Confirm DNS Pods are running
kubectl get pods --all-namespaces

# Perform On SLAVE ONLY
kubeadm join --token $token

