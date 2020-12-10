#!/bin/bash

set -ex

EXTERNAL_URL="https://@@{HOST_NAME}@@"

# Install Dependencies
sudo dnf install -y curl policycoreutils openssh-server postfix
sudo systemctl enable --now sshd

# Set Firewall Rules
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo systemctl reload firewall

# Create GitLab Repo
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash

# Install GitLab
sudo $EXTERNAL_URL dnf install -y gitlab-ce