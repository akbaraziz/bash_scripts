#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script date: 06/19/2020
# Script ver: 1.0
# Script tested on OS: CentOS 7.x
# Script purpose: To install Docker, Flannel, Kubernetes, Kubernetes Dashboard, Kubernetes Metric Server, and Helm Charts

#--------------------------------------------------

set -ex

# System Variables
HOST_NAME=`hostname -f`
IPADDR=`ip route get 1 | awk '{print $NF;exit}'`
KUBE_NETWORK=10.244.0.0/16

kube_admin=k8admin # Account that will have permissions to run Kubernetes and also Kubernetes-Dashboard 

# Create new Kubernetes user with sudo rights
sudo useradd -G wheel $kube_admin
echo P@ssword1 | passwd --stdin "$kube_admin"

# Content URL's
FLANNEL_URL=https://raw.githubusercontent.com/coreos/flannel/master/Documentation
DOCKER_URL=https://storebits.docker.com/ee/m/<dockersubscriptionnumber>
EPEL_URL=https://dl.fedoraproject.org/pub/epel

# Change Host Name
sudo hostnamectl set-hostname ${HOST_NAME}

sudo echo ${HOST_NAME} | tee /etc/hostname
sudo sed -i -E 's/^127.0.1.1.*/127.0.1.1\t'"${HOST_NAME}"'/' /etc/hosts
sudo sed -i -E 's/^127.0.1.1.*/127.0.1.1\t'"${HOST_NAME}"'/' /etc/sysconfig/network
sudo echo -e ""${IPADDR}" \t "${HOST_NAME}"" >> /etc/hosts

# Create EPEL Repository
sudo yum install -y ${EPEL_URL}/epel-release-latest-7.noarch.rpm

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

# Disable SELinux
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

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
sudo yum install -y --quiet docker-ee docker-ee-cli containerd.io

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
sudo yum install -y --quiet kubelet kubeadm kubectl –disableexcludes=kubernetes

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

# Pull Docker Images
kubeadm config images pull

# Initialize Kubernetes Master
kubeadm init --apiserver-advertise-address=$IPADDR --pod-network-cidr=${KUBE_NETWORK}

# Cluster Configure
mkdir -p /home/$kube_admin/.kube
cp -i /etc/kubernetes/admin.conf /home/$kube_admin/.kube/config
chown $kube_admin:$kube_admin /home/$kube_admin/.kube/config

# Get Flannel Config file
sudo -u $kube_admin kubectl apply -f ${FLANNEL_URL}/kube-flannel.yml

# Check status of Master Node
sudo -u $kube_admin kubectl get nodes
sleep 10

# Check status of Pods
sudo -u $kube_admin kubectl get pods --all-namespaces

# Install Kubernetes Metric Server
sudo -u $kube_admin kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.6/components.yaml

# Verify Metric Server Deployment
sudo -u $kube_admin kubectl get deployment metrics-server -n kube-system

# Create kubeadmin-service account
sudo -u $kube_admin cat > /var/tmp/kubeadmin-service-account.yaml <<"EOF"
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kubeadmin
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: kubeadmin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: kubeadmin
  namespace: kube-system
EOF

# Apply the Service Account
sudo -u $kube_admin kubectl apply -f /var/tmp/kubeadmin-service-account.yaml

# Download and Install Helm Charts
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# Add Helm Repo for Kubernetes Dashboard
helm repo add stable https://kubernetes-charts.storage.googleapis.com

# Install Kubernetes Dashboard
sudo -u $kube_admin kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.1/aio/deploy/recommended.yaml
#helm install kubernetes-dashboard stable/kubernetes-dashboard --set rbac.clusterAdminRole=true

# Get Helm Services
sudo -u $kube_admin kubectl get services

# Get Cluster Info
sudo -u $kube_admin kubectl cluster-info

# Get Dashboard Token
sudo -u $kube_admin kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep kubeadmin | awk '{print $1}')

# Start Proxy for Kubernetes Dashboard
sudo -u $kube_admin kubectl proxy &

echo "End of Installation"
