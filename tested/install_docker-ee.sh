#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script date: 06/05/2020
# Script ver: 1.0
# Script tested on OS: CentOS 7.x
# Script purpose: Install Docker EE - Must supply the Docker Hub URL for your account

#--------------------------------------------------

set -ex

export dockerurl=https://storebits.docker.com/ee/m/subscription-id/centos

# Disable swap
sudo swapoff -a
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

# Install Docker EE
sudo rpm --import $dockerurl/gpg
sudo -E sh -c 'echo "$dockerurl" > /etc/yum/vars/dockerurl'
sudo sh -c 'echo "7" > /etc/yum/vars/dockerosversion'
sudo yum install -y yum-utils device-mapper-persistent-date lvm2
sudo yum-config-manager --enable rhel-7-server-extras-rpms
sudo yum makecache fast
sudo -E yum-config-manager --add-repo "$dockerurl/docker-ee.repo"
sudo yum install -y docker-ee docker-ee-cli containerd.io

# Setup daemon
mkdir -p /etc/docker
sudo cat > /etc/docker/daemon.json <<EOL
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

# Enable and Restart Docker
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker

# Post Install Steps
sudo usermod -aG docker $USER
