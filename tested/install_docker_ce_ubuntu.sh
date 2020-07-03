#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script date: 06/0507/2020
# Script ver: 1.0
# Script tested on OS: Ubuntu 20.04
# Script purpose: Install Docker CE for Ubuntu Systems. 

#--------------------------------------------------

set -ex

# Install Docker Pre-Reqs
sudo apt-get -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common

# Add Docker Repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# Install Docker CE
sudo apt update -y
sudo apt-cache policy docker-ce
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Add local user to Docker
sudo usermod -aG docker $USER

# Verify Docker Install
sudo docker container run hello-world
