#!/bin/bash

set -ex

externalURL=http://gitlabci.lab.local
sudo yum install -y curl policycoreutils-python openssh-server openssh-clients
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo systemctl reload firewalld

sudo yum install postfix
sudo systemctl enable postfix
sudo systemctl start postfix

curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash

sudo EXTERNAL_URL="$externalURL" yum install -y gitlab-ce

