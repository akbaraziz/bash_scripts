#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/tested/remote_network_config.sh
# Script create date: 07/02/2020
# Script ver: 1.0.0
# Script purpose: Remove Network Configuration from NIC
# Script tested on OS: CentOS 7.x
#--------------------------------------------------

set -ex

# Remove Net Rules
test -f /etc/udev/rules.d/70-persistent-net.rules && rm -f /etc/udev/rules.d/70-persistent-net.rules

# The script is looking for eth0 but you can change it to match your system config
# Delete UUID and Network Info from /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i '/UUID/d' /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i '/IPADDR/d' /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i '/NETMASK/d' /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i '/GATEWAY/d' /etc/sysconfig/network-scripts/ifcfg-eth0

# Delete /etc/hosts entry
sed -i '3,d$' /etc/hosts
