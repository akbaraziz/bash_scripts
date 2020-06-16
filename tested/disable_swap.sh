#!/bin/bash
# To disable Swap partition on inux systems and comment out the partition in /etc/fstab.
# Created by: Akbar Aziz
# Date: 06/05/2020
# Version: 1.0

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
