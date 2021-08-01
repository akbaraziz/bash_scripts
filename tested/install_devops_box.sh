#!/bin/bash

set -ex

if [ -e /etc/redhat-release ] ; then
  REDHAT_BASED=true
fi

# Variables Used
TERRAFORM_VERSION="1.0.3"
PACKER_VERSION="1.7.4"
USER="@@{USER_NAME}@@"

# create new ssh key
[[ ! -f /home/ubuntu/.ssh/mykey ]] \
&& sudo mkdir -p /home/${USER}/.ssh \
&& sudo ssh-keygen -f /home/${USER}/.ssh/mykey -N '' \
&& sudo chown -R ${USER}:${USER} /home/${USER}/.ssh

# install packages
if [ ${REDHAT_BASED} ] ; then
  yum -y update
  yum install -y docker ansible unzip wget yum-utils python3
  yum-config-manager --add-repo https://rpm.releases.hashicorp.com/$release/hashicorp.repo
else
  apt-get update
  apt-get -y install docker.io ansible unzip python3-pip
  pip3 install --upgrade pip
fi

# add docker privileges
usermod -G docker ${USER}
sudo mkdir -p /home/${USER}/.cache
sudo chown -R ${USER}:${USER} /home/${USER}

# install awscli and ebcli
export PATH=$PATH:/home/akbar/.local/bin
sudo pip3 install -U botocore && pip3 install botocore --upgrade --user
sudo pip3 install -U awscli && pip3 install awscli --upgrade --user
sudo pip3 install -U awsebcli && pip3 install awsebcli --upgrade --user
sudo pip3 install -U azure-cli && pip3 install azure-cli --upgrade --user

#terraform
T_VERSION=$(/usr/local/bin/terraform -v | head -1 | cut -d ' ' -f 2 | tail -c +2)
T_RETVAL=${PIPESTATUS[0]}

[[ $T_VERSION != $TERRAFORM_VERSION ]] || [[ $T_RETVAL != 0 ]] \
&& wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
&& unzip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin \
&& rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# packer
P_VERSION=$(/usr/local/bin/packer -v)
P_RETVAL=$?

[[ $P_VERSION != $PACKER_VERSION ]] || [[ $P_RETVAL != 1 ]] \
&& wget -q https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip \
&& unzip -o packer_${PACKER_VERSION}_linux_amd64.zip -d /usr/local/bin \
&& rm packer_${PACKER_VERSION}_linux_amd64.zip

# clean up
if [ ! ${REDHAT_BASED} ] ; then
  apt-get clean
fi