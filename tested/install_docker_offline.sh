#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/blob/master/tested/install_docker_offline.sh
# Script date: 06/05/2020
# Script ver: 1.0.0
# Script purpose: Install Docker CE Off-line
# Script tested on OS: CentOS 7.x
#--------------------------------------------------

set -ex

##First - Download the files on a system that has Internet Access
# Install EPEL Repo
sudo yum install -y epel-release.noarch

# Create Docker CE Repo
sudo yum-config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo

# Build Yum Cache
sudo yum makecache fast

# Create Directory to Download Docker CE and dependent packages
sudo mkdir -p /var/tmp/docker
sudo cd /var/tmp/docker
sudo yumdownloader --resolve docker -ce

# Compress all downloaded files
sudo tar cvzf docker.tar.gz *

# Pull Docker Images
sudo docker pull imagename

# Save Docker Images
sudo docker save image/image > ~/docker/imagename.tar
sudo scp image.tar user@remoteserver:/var/tmp

# On Remote Server
sudo docker load < images.tar

## No Internet System Steps
# Copy the above file to system with no Internet
sudo scp docker.tar.gz user@remoteserver:/var/tmp
sudo mkdir -p /var/tmp/docker
sudo tar xvf /var/tmp/docker.tar.gz -C ~/docker

# Install Docker packages
sudo cd ~/docker
sudo rpm -ivh --replacefiles --replacepkgs *.rpm

# Start and Enable Docker
sudo systemctl enable --now docker

