#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/blob/master/tested/copy_ssh_id_rsa_multiple_hosts.sh
# Script date: 06/27/2020
# Script ver: 1.0.0
# Script purpose: To copy id_rsa.pub file to multiple servers defined in a list. It will install sshpass
# Script tested on OS: CentOS 7.x
#--------------------------------------------------

set -ex

# Install sshpass
sudo yum -y install sshpass

# Copy id_rsa.pub to multiple servers defined in a file
for ip in $(cat /home/list_of_servers); do
    ssh-copy-id -i ~/.ssh/id_rsa.pub $ip
done