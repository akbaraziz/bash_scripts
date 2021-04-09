#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/tested/install_prometheus_ubuntu.sh
# Script date: 06/05/2020
# Script ver: 1.0.0
# Script purpose: Install Octopus Tentacle
# Script tested on CentOS 7.x
#--------------------------------------------------

set -ex

# Download Octopus Repo
wget https://rpm.octopus.com/tentacle.repo -O /etc/yum.repos.d/tentacle.repo

# Install Octopus Tentacle
sudo yum install -y tentacle --quiet