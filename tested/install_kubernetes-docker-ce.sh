#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script date: 03/06/2021
# Script ver: 1.2
# Script tested on OS: Red Hat 7.x
# Script purpose: To install Docker, Flannel, Kubernetes, Kubernetes Dashboard, Kubernetes Metric Server, Helm Charts, and NGINX Pod
# Comment: This is to install on Master Node. It does not take into account multiple master nodes
# which would require SSL certs to communicate. The worker nodes must be added to make it a cluster.

#--------------------------------------------------
set -ex

# System Variables
HOST_NAME=`hostname -f`
IPADDR=`ip route get 1 | awk '{print $NF;exit}'`
KUBE_NETWORK=10.244.0.0/16
DOCKER_VERSION=19.03
KUBE_ADMIN=k8admin # Account that will have permissions to run Kubernetes and also Dashboard

# Create new Kubernetes user with sudo rights
id -u $KUBE_ADMIN &>/dev/null || useradd $KUBE_ADMIN -d /home/$KUBE_ADMIN
sudo usermod -a -G wheel $KUBE_ADMIN
echo P@ssword1 | passwd --stdin "$KUBE_ADMIN"

# Content URL's
FLANNEL_URL=/
#DOCKER_URL=https://download.docker.com/linux/centos/docker-ce.repo
DOCKER_URL=https://download.docker.com/linux/rhel/docker-ce.repo #Red Hat Repo
EPEL_URL=https://dl.fedoraproject.org/pub/epel

# Change Host Name
sudo hostnamectl set-hostname ${HOST_NAME}

sudo echo ${HOST_NAME} | tee /etc/hostname
sudo sed -i -E 's/^127.0.1.1.*/127.0.1.1\t'"${HOST_NAME}"'/' /etc/hosts
sudo sed -i -E 's/^127.0.1.1.*/127.0.1.1\t'"${HOST_NAME}"'/' /etc/sysconfig/network
sudo echo -e ""${IPADDR}" \t "${HOST_NAME}"" >> /etc/hosts

# Create EPEL Repository
sudo yum install -y ${EPEL_URL}/epel-release-latest-7.noarch.rpm

# Additional Repos for Red Hat 7
sudo subscription-manager repos --enable=rhel-7-server-rpms \
--enable=rhel-7-server-extras-rpms \
--enable=rhel-7-server-optional-rpms

# Disable SELinux
sudo setenforce 0
sudo sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

# Disable swap
sudo swapoff -a
sudo sed -i '/ swap/ s/^/#/' /etc/fstab

# Disable Firewall
sudo systemctl disable firewalld
sudo systemctl stop firewalld

# Enable IPTables
sudo yum install -y iptables-services.x86_64
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
sudo yum install -y yum-utils device-mapper-persistent-data lvm2 container-selinux iscsi-initiator-utils socat

# Remove Existing Version of Docker if installed
# Check for existing version of Docker and remove if found
if rpm -qa | grep -q docker*; then
    yum remove -y docker*;
else
    echo "Not Installed"
fi

# Create Docker Repo
cat <<EOF > /etc/yum.repos.d/docker-ce.repo
[docker-ce-stable]
name=Docker CE Stable - $basearch
baseurl=https://download.docker.com/linux/rhel/7/$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/rhel/gpg
EOF

# Install Docker
sudo yum install -y docker-ce-$DOCKER_VERSION docker-ce-cli-$DOCKER_VERSION

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
  {
	"dns": ["10.10.10.10", "8.8.4.4"]
  }
}
EOL

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

# Install Kubernetes
sudo yum install -y kubelet kubeadm kubectl –-disableexcludes=kubernetes

# Enable and Start Services
sudo systemctl enable --now docker
sudo systemctl enable --now kubelet

# Enable bash completion for both
kubeadm completion bash > /etc/bash_completion.d/kubeadm
kubectl completion bash > /etc/bash_completion.d/kubectl

# Confirm Docker and Kubelet are running
sudo systemctl is-active docker && echo "docker is running" || echo "docker is NOT running"
sudo systemctl is-active kubelet && echo "kubelet is running" || echo "kubelet is NOT running"

# Pull Docker Images
kubeadm config images pull

# Initialize Kubernetes Master
kubeadm init --apiserver-advertise-address=$IPADDR --pod-network-cidr=${KUBE_NETWORK}

# Cluster Configure
mkdir -p /home/$KUBE_ADMIN/.kube
cp -i /etc/kubernetes/admin.conf /home/$KUBE_ADMIN/.kube/config
chown $KUBE_ADMIN:$KUBE_ADMIN /home/$KUBE_ADMIN/.kube/config

# Get Flannel Config file
sudo -u $KUBE_ADMIN kubectl apply -f ${FLANNEL_URL}/kube-flannel.yml

# Check status of Master Node
sudo -u $KUBE_ADMIN kubectl get nodes
sleep 10

# Check status of Pods
sudo -u $KUBE_ADMIN kubectl get pods --all-namespaces

# Create kubeadmin-service account
sudo -u $KUBE_ADMIN cat > /var/tmp/kubeadmin-service-account.yaml <<"EOF"
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kubeadmin
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
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
sudo -u $KUBE_ADMIN kubectl apply -f /var/tmp/kubeadmin-service-account.yaml

# Download and Install Helm Charts
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# Add Helm Repo for Kubernetes Dashboard
helm repo add stable https://charts.helm.sh/stable

# Install Kubernetes Dashboard
sudo -u $KUBE_ADMIN $ kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml

# Install Kubernetes Metrics Server
sudo -u $KUBE_ADMIN $ kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Verify Metric Server Deployment
sudo -u $KUBE_ADMIN kubectl get deployment metrics-server -n kube-system

# Get Helm Services
sudo -u $KUBE_ADMIN kubectl get services

# Get Cluster Info
sudo -u $KUBE_ADMIN kubectl cluster-info

# Get Node Info
sudo -u $KUBE_ADMIN kubectl get nodes

# Get Pods Info
sudo -u $KUBE_ADMIN kubectl get pods --all-namespaces

# Get Dashboard Token
sudo -u $KUBE_ADMIN kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep kubeadmin | awk '{print $1}')

# Start Proxy for Kubernetes Dashboard
sudo -u $KUBE_ADMIN kubectl proxy &

# Create NGINX Pod
sudo -u $KUBE_ADMIN kubectl create deployment nginx --image=nginx
sudo -u $KUBE_ADMIN kubectl create service nodeport nginx --tcp=80:80

echo "End of Installation."