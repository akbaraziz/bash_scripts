#!/bin/bash

# Download and Unzip Terraform
wget https://releases.hashicorp.com/terraform/0.12.9/terraform_0.12.9_linux_amd64.zip
sudo unzip terraform_0.12.9_linux_amd64.zip -d /usr/local/bin

# Get Terraform Version
terraform version