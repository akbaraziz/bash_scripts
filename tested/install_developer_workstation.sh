#!/bin/bash

set -ex

# Variables Used
USER="@@{LinuxUser.username}@@"
PASSWORD="@@{LinuxUser.secret}@@"

# Add new User
echo "@@{user_creds}@@" | sudo -S ls
sudo useradd $USER -m -d /home/$USER -p $PASSWORD
sudo usermod -G sudo $USER
#echo ${PASSWORD} | passwd --stdin "$USER"

echo "AllowUsers root $USER @@{LinuxAdmin.username}@@" | sudo tee -a /etc/ssh/sshd_config
echo "$USER		 ALL=(ALL:ALL)	ALL" | sudo tee -a /etc/sudoers
echo "@@{LinuxAdmin.username}@@		ALL=(ALL:ALL) ALL" | sudo tee -a /etc/sudoers

# Create User SSH Key
#sudo mkdir -p /home/${USER}/.ssh \
#&& sudo ssh-keygen -f /home/${USER}/.ssh/mykey -N '' \
#&& sudo chown -R ${USER}:${USER} /home/${USER}/.ssh

# Install Packages
sudo apt-get -y -qq install docker.io ansible unzip python3-pip wget apt-transport-https ca-certificates curl gnupg software-properties-common git zsh
sudo pip3 install -qq --upgrade pip

# Add Docker Permissions
sudo usermod -G docker ${USER}
sudo mkdir -p /home/${USER}/.cache
sudo chown -R ${USER}:${USER} /home/${USER}/.cache

# Install AWS and Azure CLI Tools
export PATH=$PATH:/home/${USER}/.local/bin
sudo pip3 install -U -qq botocore && sudo pip3 install -qq botocore --upgrade --user 
sudo pip3 install -U -qq awscli && sudo pip3 install -qq awscli --upgrade --user
sudo pip3 install -U -qq azure-cli && sudo pip3 install -qq azure-cli --upgrade --user

# Install Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get -y -qq install terraform

# Install Packer
sudo apt-get -y -qq install packer

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install OhMyZSH
git clone https://github.com/jotyGill/quickz-sh.git
cd quickz-sh
sudo ./quickz.sh -c