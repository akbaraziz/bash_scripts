#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script date: 06/27/2020
# Script ver: 1.0
# Script tested on OS: CentOS 7.x
# Script purpose: To copy id_rsa.pub file to multiple servers defined in a list. "SSHPASS must be installed before executing."

#--------------------------------------------------

set -ex

# Copy id_rsa.pub to multiple servers defined in a file
for ip in `cat /home/list_of_servers`; do
    ssh-copy-id -i ~/.ssh/id_rsa.pub $ip
done