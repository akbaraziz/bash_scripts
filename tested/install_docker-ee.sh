s#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script date: 06/05/2020
# Script ver: 1.0
# Script tested on OS: CentOS 7.x
# Script purpose: Install Docker EE - Must supply the Docker Hub URL for your account

#--------------------------------------------------

set -ex

DOCKER_URL=

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
export DOCKERURL="{DOCKER_URL}"
sudo -E sh -c 'echo "$DOCKERURL/rhel" > /etc/yum/vars/dockerurl'
sudo sh -c 'echo "7" > /etc/yum/vars/dockerosversion'
sudo yum install -y yum-utils device-mapper-persistent-date lvm2
sudo yum-config-manager --enable rhel-7-server-extras-rpms
sudo -E yum-config-manager --add-repo "$DOCKERURL/rhel/docker-ee.repo"
sudo yum install -y docker-ee docker-ee-cli containerd.io

# Setup daemon
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
