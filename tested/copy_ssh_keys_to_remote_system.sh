#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script create date: 07/02/2020
# Script ver: 1.0
# Script tested on OS: CentOS 7.x
# Script purpose: 

#--------------------------------------------------

set -ex

# To copy id_rsa.pub file to remote linux system. "SSHPASS must be installed before executing."
# Copy SSH Keys to Remote Server 
sshpass -p "PASSWORD" ssh-copy-id -o StrictHostKeyChecking=no USERNAME@IP