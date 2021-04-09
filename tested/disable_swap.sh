#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/blob/master/tested/disable_swap.sh
# Script date: 06/05/2020
# Script ver: 1.0.0
# Script tested on OS: CentOS 7.x
# Script purpose: Disable Swap Volume
#--------------------------------------------------

set -ex

# Disabel Swap
sudo swapoff -a
sed -i '/ swap/ s/^/#/' /etc/fstab