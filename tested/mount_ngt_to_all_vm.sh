#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script create date: 07/02/2020
# Script ver: 1.0
# Script tested on OS: CentOS 7.x
# Script purpose: Mount Nutanix NGT to all hosted VM's

#--------------------------------------------------

set -ex

for i in $(ncli vm list | grep "Id" | grep -v Hypervisor | awk -F ":" '{print $4}');do \
ncli ngt mount vm-id=$i;done