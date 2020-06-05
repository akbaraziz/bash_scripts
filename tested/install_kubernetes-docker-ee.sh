#!/bin/bash
# To install Kubernetes, Docker EE, Flannel on CentOS and Redhat 7 systems.
# Created by: Akbar Aziz
# Date: 06/05/2020
# Version: 1.0

set -ex

HOST_NAME=
IPADDR=

KUBE_SERVER_URL=https://dl.k8s.io/v1.18.0/kubernetes-server-linux-amd64.tar.gz
KUBE_NODE_URL=https://dl.k8s.io/v1.18.0/kubernetes-node-linux-amd64.tar.gz
FLANNEL_URL=https://raw.githubusercontent.com/coreos/flannel/master/Documentation
DOCKER_URL="Enter your Docker HUB URL Here"
EPEL_URL=https://dl.fedoraproject.org/pub/epel

KUBE_NETWORK=10.244.0.0/16

# Change Host Name
sudo hostnamectl set-hostname ${HOST_NAME}

sudo echo ${HOST_NAME} | tee /etc/hostname
sudo sed -i -E 's/^127.0.1.1.*/127.0.1.1\t'"${HOST_NAME}"'/' /etc/hosts
sudo sed -i -E 's/^127.0.1.1.*/127.0.1.1\t'"${HOST_NAME}"'/' /etc/sysconfig/network
sudo echo -e ""${IPADDR}" \t "${HOST_NAME}"" >> /etc/hosts

# Create EPEL Repository
yum install -y ${EPEL_URL}/epel-release-latest-7.noarch.rpm

# Create Docker Repo
export DOCKERURL="${DOCKER_URL}"
yum-config-manager --add-repo $DOCKERURL/rhel/docker-ee.repo
sudo -E sh -c 'echo "$DOCKERURL/rhel" > /etc/yum/vars/dockerurl'
sudo -E sh -c 'echo "7.6" > /etc/yum/vars/dockerosversion'

# Create Kubernetes Repo
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# Disable swap
swapoff -a
sed -i '/ swap/ s/^/#/' /etc/fstab

# Disable Firewall
systemctl disable firewalld 
systemctl stop firewalld

# Enable IPTables 
yum install -y --quiet iptables-services.x86_64
systemctl start iptables
systemctl enable iptables
systemctl unmask iptables
iptables -F
service iptables save

# Configure IPTables to see Bridged Traffic
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

# Set SELinux in permissive mode
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Install Docker Pre-Reqs
yum install -y --quiet yum-utils device-mapper-persistent-data lvm2 container-selinux iscsi-initiator-utils socat

# Remove Existing Version of Docker if installed
# Check for existing version of Docker and remove if found
if rpm -qa | grep -q docker*; then
    yum remove -y docker*;
else
    echo Not Installed
fi

# Remove Existing Docker Repo if exists
FILE=/etc/yum.repos.d/docker*.repo
if [ -f "$FILE" ]; then
    rm /etc/yum.repos.d/docker*.repo;
else
    echo "$FILE does not exist"
fi

# Install Docker
yum install -y docker-ee docker-ee-cli containerid.o

# Setup daemon
mkdir -p /etc/docker
cat >/etc/docker/daemon.json <<EOL
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOL

# Install Kubernetes
yum install -y kubelet kubeadm kubectl –disableexcludes=kubernetes

# Enable and Start Services
systemctl enable docker
systemctl enable kubelet
systemctl start docker
systemctl start kubelet

# Enable bash completion for both
kubeadm completion bash > /etc/bash_completion.d/kubeadm
kubectl completion bash > /etc/bash_completion.d/kubectl

# activate the completion
. /etc/profile

# Initialize Kubernetes Master
kubeadm init --pod-network-cidr=${KUBE_NETWORK}

# Cluster Configure
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# Get Flannel Config file
kubectl apply -f ${FLANNEL_URL}/kube-flannel.yml 