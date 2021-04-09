#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/blob/master/tested/copy_ssh_keys_to_remote_system.sh
# Script create date: 07/02/2020
# Script ver: 1.0.0
# Script purpose: To copy keys to remote server
# Script tested on OS: CentOS 7.x
#--------------------------------------------------

set -ex

# Install sshpass
sudo yum -y install sshpass

# Copy SSH Keys to Remote Server
sshpass -p "PASSWORD" ssh-copy-id -o StrictHostKeyChecking=no USERNAME@IP