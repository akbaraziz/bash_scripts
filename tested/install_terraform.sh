#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script date: 06/05/2020
# Script ver: 1.0
# Script tested on OS: CentOS 7.x
# Script purpose: Install Terraform

#--------------------------------------------------


set -ex

TERRA_VER=

echo $PATH

# Download and Unzip Terraform
wget https://releases.hashicorp.com/terraform/v${TERRA_VER}/terraform_${TERRA_VER}_linux_amd64.zip
sudo unzip terraform_${TERRA_VER}_linux_amd64.zip -d /usr/local/bin

# Get Terraform Version
sudo terraform version

# Enable Terrafor Tab Completion
sudo terraform -install-autocomplete
