#!/bin/bash

set -ex

# Install Pre-Reqs
sudo yum install -y curl policycoreutils-python openssh-server postfix


# Download and Install GitLab
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash
sudo yum -y install gitlab-ce

# Add Firewall Rules
sudo firewall-cmd --permanent --zone=public --add-service=http
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo firewall-cmd --reload
