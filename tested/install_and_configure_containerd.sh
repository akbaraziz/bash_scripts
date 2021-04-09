#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/blob/master/tested/install_and_configure_containerd.sh
# Script date: 06/05/2020
# Script ver: 1.0.0
# Script purpose: To install and configure containerd.
# Script tested on OS: CentOS and Redhat 7.x
#--------------------------------------------------

set -ex

# Pre-Reqs for Containerd
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

sudo yum install -y yum-utils device-mapper-persistent-data lvm2 --quiet

# Install Docker Repo
sudo yum-config-manager \
--add-repo \
https://download.docker.com/linux/centos/docker-ce.repo

# Install containerd
sudo yum clean all
sudo yum install -y containerd.io --quiet

# Configure containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

# Restart containerd
sudo systemctl restart containerd