#!/bin/bash
# To disable Swap partition on inux systems and comment out the partition in /etc/fstab.
# Created by: Akbar Aziz
# Date: 06/05/2020
# Version: 1.0


set -ex

# Disable SWAP volume
swapoff -a
sed -i '/ swap/ s/^/#/' /etc/fstab