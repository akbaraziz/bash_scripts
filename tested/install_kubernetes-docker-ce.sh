#!/bin/bash

set -ex

#### This script will reboot the target when completed. Please use caution ####

# Disable SELinux
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

# Disable Firewall
systemctl disable firewalld
systemctl stop firewalld

# Enable br_netfilter Kernel Module"
modprobe overlay
modprobe br_netfilter
# Setup required sysctl params, these persist across reboots.
cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sysctl --system

# Disable swap
# does the swap file exist?
grep -q "swapfile" /etc/fstab

# if it does then remove it
if [ $? -eq 0 ]; then
	echo 'swapfile found. Removing swapfile.'
	sed -i '/swapfile/d' /etc/fstab
	echo "3" > /proc/sys/vm/drop_caches
	swapoff -a
	rm -f /swapfile
else
	echo 'No swapfile found. No changes made.'
fi

# Remove Existing Version of Docker
sudo yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine

# Remove Existing Docker Repo
sudo rm /etc/yum.repos.d/docker*.repos

# Install Docker CE
sudo yum install -y yum-utils device-mapper-persistent-data lvm2

# Create Docker Repository
yum-config-manager \
  --add-repo \
  https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker CE.
yum install -y docker-ce

# Setup daemon
sudo cat >/etc/docker/daemon.json <<EOL
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

# Configure Docker Cgroup Driver
sed -i '/^ExecStart/ s/$/ --exec-opt native.cgroupdriver=systemd/' /usr/lib/systemd/system/docker.service 

# Restart Docker
sudo systemctl daemon-reload
sudo systemctl restart docker

# Enable Docker on Start
sudo systemctl enabled docker

# Post Install Steps
sudo groupadd docker
sudo usermod -aG docker $USER


# Add Kubernetes Repo
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
yum install -y kubelet kubeadm kubectl etcd


# Install CRI-O
# Install prerequisites
yum-config-manager --add-repo=https://cbs.centos.org/repos/paas7-crio-311-candidate/x86_64/os/

# Install CRI-O
#yum install -y --nogpgcheck cri-o
#ln -s /usr/sbin/runc /usr/bin/runc

# Starting Kubernetes
systemctl start docker && systemctl enable docker
systemctl start kubelet && systemctl enable kubelet
#systemctl start crio && systemctl enable crio

# Changing the cgroup-driver to systemd
#sed -i 's/cgroup-driver=systemd/cgroup-driver=cgroupfs/g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

#reboot