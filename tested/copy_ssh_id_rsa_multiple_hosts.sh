#!/bin/bash
# To copy id_rsa.pub file to multiple servers defined in a list. "SSHPASS must be installed before executing."
# Created by: Akbar Aziz
# Date: 06/05/2020
# Version: 1.0


set -ex

# Copy id_rsa.pub to multiple servers defined in a file
for ip in `cat /home/list_of_servers`; do
    ssh-copy-id -i ~/.ssh/id_rsa.pub $ip
done