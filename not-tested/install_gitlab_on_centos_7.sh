#!/bin/bash

set -ex

EXTERNAL_URL="https://@@{HOST_NAME}@@"

# Install Pre-Reqs
sudo yum install -y curl policycoreutils-python openssh-server postfix

# Add Firewall Rules
sudo firewall-cmd --permanent --zone=public --add-service=http
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo firewall-cmd --reload

# Create GitLab Repo
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash

# Install GitLab
sudo $EXTERNAL_URL yum -y install gitlab-ce