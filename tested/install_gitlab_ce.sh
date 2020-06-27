#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script date: 06/23/2020
# Script ver: 1.0
# Script tested on OS: CentOS 7.x
# Script purpose: Install GitLab Community Edition

#--------------------------------------------------


set -ex

GIT_LAB_REPO=https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee
GIT_LAB_INSTANCE="Enter your Instance Name Here"

# Install Pre-Req's
sudo yum install -y curl policycoreutils-python openssh-server openssh-clients

# Enable and Start SSH Daemon
sudo systemctl enable sshd
sudo systemctl start sshd

# Add Firewall Rules if Running
if [ `systemctl is-active firewalld` ]
then
    firewall-cmd --permanent --add-service=http
    firewall-cmd --permanent --add-service=https
    firewall-cmd --reload
else
    firewall_status=inactive
fi

# Install PostFix to send notification emails
sudo yum install postfix

# Enable and Start Postfix
sudo systemctl enable postfix
sudo systemctl start postfix

# Check if Curl is installed
curl_check ()
{
  echo "Checking for curl..."
  if command -v curl > /dev/null; then
    echo "Detected curl..."
  else
    echo "Installing curl..."
    yum install -d0 -e0 -y curl
  fi
}

# Create GitLab Rep
curl ${GIT_LAB_REPO}/script.rpm.sh | sudo bash

# Install GitLab-CE
sudo EXTERNAL_URL="${GIT_LAB_INSTANCE}" yum install -y gitlab-ce

