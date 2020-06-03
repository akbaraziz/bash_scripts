#!/bin/bash

set -ex

# Disable SELinux
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

# Disable swap
swapoff -a
sed -i '/ swap/ s/^/#/' /etc/fstab

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

#Install Docker CE
sudo yum install -y yum-utils device-mapper-persistent-data lvm2

# Create Docker Repository
yum-config-manager \
  --add-repo \
  https://download.docker.com/linux/centos/docker-ce.repo

## Install Docker CE.
yum install -y docker-ce

# Setup daemon
sudo mkdir -p /etc/docker
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

#Restart Docker
sudo systemctl daemon-reload
sudo systemctl restart docker

#Post Install Steps
sudo usermod -aG docker $USER

#Enable Docker on Start
sudo systemctl enable docker