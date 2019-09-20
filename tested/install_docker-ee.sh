#!/bin/bash

set -ex

#Disable SELinux
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

#Disable swap
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

#Remove Existing Version of Docker
sudo yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine

#Remove Existing Docker Repo
sudo rm /etc/yum.repos.d/docker*.repos

#Install Docker EE
export DOCKERURL=""
sudo -E sh -c 'echo "$DOCKERURL/rhel" > /etc/yum/vars/dockerurl'
sudo sh -c 'echo "7" > /etc/yum/vars/dockerosversion'
sudo yum install -y yum-utils device-mapper-persistent-date lvm2
sudo yum-config-manager --enable rhel-7-server-extras-rpms
sudo -E yum-config-manager --add-repo "$DOCKERURL/rhel/docker-ee.repo"
sudo yum -y install docker-ee docker-ee-cli containerd.io

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

#Restart Docker
sudo systemctl daemon-reload
sudo systemctl restart docker

#Post Install Steps
sudo usermod -aG docker $USER

#Enable Docker on Start
sudo systemctl enable docker