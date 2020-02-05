#!/bin/sh

set -ex

# Remove Net Rules
test -f /etc/udev/rules.d/70-persistent-net.rules && rm -f /etc/udev/rules.d/70-persistent-net.rules

# Delete UUID and Network Info from /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i '/UUID/d' /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i '/IPADDR/d' /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i '/NETMASK/d' /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i '/GATEWAY/d' /etc/sysconfig/network-scripts/ifcfg-eth0

# Delete /etc/hosts entry
sed -i '3,d$' /etc/hosts
