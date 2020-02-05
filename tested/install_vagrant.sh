#!/bin/bash

set -ex

VAGRANT_HOME=/opt/vagrant

# Download Vagrant
sudo yum install -y https://releases.hashicorp.com/vagrant/2.2.5/vagrant_2.2.5_x86_64.rpm

# Intitialize Ubuntu Vagrant File
sudo ./vagrant init ubuntu/bionic64