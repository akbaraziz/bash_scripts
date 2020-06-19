#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script date: 06/19/2020
# Script ver: 1.1
# Script tested on OS: CentOS 7.x
# Script purpose: To install Docker, Kubernetes, and Flannel

#--------------------------------------------------

set -ex

# System Variables
HOST_NAME=`hostname -f`
IPADDR=`ip route get 1 | awk '{print $NF;exit}'`
KUBE_NETWORK=10.244.0.0/16
KUBE_VER=v1.18.0
kube_admin=kubeadmin 

# Create new user with Sudo Rights
sudo useradd -G wheel $kube_admin
echo P@ssword1 | passwd --stdin "$kube_admin"

# Content URL's
KUBE_SERVER_URL=https://dl.k8s.io/${KUBE_VER}/kubernetes-server-linux-amd64.tar.gz
KUBE_NODE_URL=https://dl.k8s.io/${KUBE_VER}/kubernetes-node-linux-amd64.tar.gz
FLANNEL_URL=https://raw.githubusercontent.com/coreos/flannel/master/Documentation
EPEL_URL=https://dl.fedoraproject.org/pub/epel
DOCKER_URL=https://download.docker.com/linux/centos/docker-ce.repo

# Change Host Name
sudo hostnamectl set-hostname ${HOST_NAME}

sudo echo ${HOST_NAME} | tee /etc/hostname
sudo sed -i -E 's/^127.0.1.1.*/127.0.1.1\t'"${HOST_NAME}"'/' /etc/hosts
sudo sed -i -E 's/^127.0.1.1.*/127.0.1.1\t'"${HOST_NAME}"'/' /etc/sysconfig/network
sudo echo -e ""${IPADDR}" \t "${HOST_NAME}"" >> /etc/hosts

# Create EPEL Repository
sudo yum install -y ${EPEL_URL}/epel-release-latest-7.noarch.rpm

# Create Docker Repo
sudo yum-config-manager --add-repo $DOCKER_URL

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
sudo systemctl disable firewalld
sudo systemctl stop firewalld

# Enable IPTables
sudo yum install -y --quiet iptables-services.x86_64
sudo systemctl start iptables
sudo systemctl enable iptables
sudo systemctl unmask iptables
sudo iptables -F
sudo service iptables save

# Configure IPTables to see Bridged Traffic
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

# Install Docker Pre-Reqs
sudo yum install -y --quiet yum-utils device-mapper-persistent-data lvm2 container-selinux iscsi-initiator-utils socat

# Remove Existing Version of Docker if installed
# Check for existing version of Docker and remove if found
if rpm -qa | grep -q docker*; then
    yum remove -y docker*;
else
    echo "Not Installed"
fi

# Remove Existing Docker Repo if exists
FILE=/etc/yum.repos.d/docker*.repo
if [ -f "$FILE" ]; then
    rm /etc/yum.repos.d/docker*.repo;
else
    echo "$FILE does not exist"
fi

# Install Docker
sudo yum install -y --quiet docker-ce docker-ce-cli containerd.io docker-ce-selinux

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
sudo yum install -y kubelet kubeadm kubectl –disableexcludes=kubernetes

# Enable and Start Services
sudo systemctl enable docker
sudo systemctl enable kubelet
sudo systemctl start docker
sudo systemctl start kubelet

# Enable bash completion for both
kubeadm completion bash > /etc/bash_completion.d/kubeadm
kubectl completion bash > /etc/bash_completion.d/kubectl

# activate the bash completion
. /etc/profile

# Confirm Docker and Kubelet are running
sudo systemctl is-active --quiet docker && echo "docker is running" || echo "docker is NOT running"
sudo systemctl is-active --quiet kubelet && echo "kubelet is running" || echo "kubelet is NOT running"

# Initialize Kubernetes Master
sudo kubeadm init --apiserver-advertise-address=$IPADDR --pod-network-cidr=${KUBE_NETWORK}


# Cluster Configure
mkdir -p /home/$kube_admin/.kube
cp -i /etc/kubernetes/admin.conf /home/$kube_admin/.kube/config
chown $kube_admin:$kube_admin /home/$kube_admin/.kube/config

# Get Flannel Config file
sudo -u $kube_admin kubectl apply -f ${FLANNEL_URL}/kube-flannel.yml

# Check status of Master Node
sudo -u $kube_admin kubectl get nodes
sleep 30

# Check status of Pods
sudo -u $kube_admin kubectl get pods --all-namespaces
