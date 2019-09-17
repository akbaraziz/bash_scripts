#!/bin/bash

set -ex

# Download Terraform
wget https://releases.hashicorp.com/terraform/0.12.8/terraform_0.12.8_linux_amd64.zip

# Extract File
unzip terraform_0.12.8_linux_amd64.zip

# Copy to /opt
mkdir -p /opt/terraform

# Set PATH to Terraform
export PATH=$PATH:/opt/terraform/