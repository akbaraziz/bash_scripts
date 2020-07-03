#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script create date: 07/02/2020
# Script ver: 1.0
# Script tested on OS: Ubuntu 20.x
# Script purpose: Update Ubuntu System

#--------------------------------------------------

set -ex

# Need to update and upgrade to get patched up
echo "@@{ub_user_creds}@@" | sudo -S ls

sudo apt-get update -y
sudo apt-get upgrade -y