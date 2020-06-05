#!/bin/bash
# To install Docker Conpose on CentOS and Redhat 7 systems.
# Created by: Akbar Aziz
# Date: 06/05/2020
# Version: 1.0


set -ex

COMPOSE_VER=

# Check if curl is installed. If not found, install curl
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

#Install Docker Compose
sudo curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VER}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

#Install Bash Command Completion
sudo curl -L https://raw.githubusercontent.com/docker/compose/${COMPOSE_VER}/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
