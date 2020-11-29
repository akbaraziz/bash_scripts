#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script date: 06/05/2020
# Script ver: 1.0
# Script tested on OS: CentOS 7.x
# Script purpose: Disable Swap Volume

#--------------------------------------------------

set -ex

# does the swap file exist?
grep -q "swapfile" /etc/fstab

# if it does then remove it
if [ $? -eq 0 ]; then
	echo 'swapfile found. Removing swapfile.'
	sed -i '/ swap/ s/^/#/' /etc/fstab
	echo "3" > /proc/sys/vm/drop_caches
	swapoff -a
	rm -f /swapfile
