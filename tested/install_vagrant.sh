#!/bin/bash

set -ex
VAGRANT_VER=2.2.9
VAGRANT_HOME=/opt/vagrant

sudo mkdir -p $VAGRANT_HOME

# Download Vagrant 2.2.9
sudo yum install -y https://releases.hashicorp.com/vagrant/${VAGRANT_VER}/vagrant_${VAGRANT_VER}_linux_amd64.zip

# Intitialize Vagrant File
sudo ./vagrant init centos/7

# Bring Up Vagrant Server (CentOS 7)
sudo vagrant up 