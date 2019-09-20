#!/bin/bash

set -ex

sudo yum install curl policycoreutils-python openssh-server
sudo yum install postfix


curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash

sudo yum install gitlab-ce

sudo firewall-cmd --permanent --zone=public --add-service=http
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo firewall-cmd --reload
