#!/bin/bash

set -ex

GITLAB_DNS_NAME="@@{HOST_NAME}@@"

# Install Dependencies
sudo dnf install -y curl policycoreutils openssh-server postfix checkpolicy policycoreutils-python-utils python3-audit python3-libsemanage python3-policycoreutils python3-setools
sudo systemctl enable --now sshd

# Set Firewall Rules
sudo firewall-cmd --permanent --zone=public --add-service=http
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo firewall-cmd --permanent --zone=public --add-service=ssh
sudo firewall-cmd --reload

# Create GitLab Repo
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash

# Install GitLab
sudo dnf install -y gitlab-ce

# Configure GitLab
if [[ "${GITLAB_DNS_NAME}x" != "x" ]]; then 
  sudo sed -i "s#external_url 'http://gitlab.example.com'#external_url 'http://${GITLAB_DNS_NAME}'#" /etc/gitlab/gitlab.rb
fi
sudo gitlab-ctl reconfigure