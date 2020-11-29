#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script date: 06/05/2020
# Script ver: 1.0
# Script tested on OS: CentOS 7.x
# Script purpose: Install Vagrant

#--------------------------------------------------

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