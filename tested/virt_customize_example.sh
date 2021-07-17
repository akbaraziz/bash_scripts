#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/blob/master/tested/add_firewall_rules.sh
# Script date: 06/05/2020
# Script ver: 1.0.0
# Script purpose: To create a VM image using Virt Customize
# Script tested on OS: CentOS and Redhat 7.x
#--------------------------------------------------

set -ex

# Install required RPM's
sudo yum -y install libguestfs libguestfs-tools --quiet
sudo virt-customize -a CentOS-8-GenericCloud-8.3.2011-20201204.2.x86_64.qcow2 --root-password password:'yourpassword'