#!/bin/bash

set -ex

#### This script will reboot the target when completed. Please use caution ####

echo "Disable SELinux"
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux


echo "Enable br_netfilter Kernel Module"
modprobe overlay
modprobe br_netfilter
# Setup required sysctl params, these persist across reboots.
cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sysctl --system


echo "Disable Swap"
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
sudo yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine

# Remove Existing Docker Repo
rm /etc/yum.repos.d/docker*.repos

# Create Docker EE Repo
export DOCKERURL=""
sudo -E sh -c 'echo "$DOCKERURL/rhel" > /etc/yum/vars/dockerurl'
sudo sh -c 'echo "7" > /etc/yum/vars/dockerosversion'

# Install Docker EE
sudo yum install -y yum-utils device-mapper-persistent-date lvm2
sudo yum-config-manager --enable rhel-7-server-extras-rpms
sudo -E yum-config-manager --add-repo "$DOCKERURL/rhel/docker-ee.repo"
sudo systemctl start docker
sudo systemctl enable docker

# Post Install Steps
sudo groupadd docker
sudo usermod -aG docker $USER