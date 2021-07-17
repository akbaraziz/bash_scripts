#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/blob/master/tested/set_kubernetes_firewall_rules.sh
# Script date: 06/05/2020
# Script ver: 1.0.0
# Script purpose: To set firewall rules for Kubernetes
# Script tested on OS: CentOS and Redhat 7.x
#--------------------------------------------------

set -ex

echo "Setting up required FW Rules..."
# Add Firewall Rules
sudo firewall-cmd --permanent --add-port=6443/tcp
sudo firewall-cmd --permanent --add-port=2379-2380/tcp
sudo firewall-cmd --permanent --add-port=10250/tcp
sudo firewall-cmd --permanent --add-port=10251/tcp
sudo firewall-cmd --permanent --add-port=10252/tcp
sudo firewall-cmd --permanent --add-port=10255/tcp
sudo firewall-cmd --permanent --add-port=8472/udp
sudo firewall-cmd --permanent --add-port=30000-32767/tcp
sudo firewall-cmd --zone=trusted --permanent --add-source=192.168.65.0/24
sudo firewall-cmd --add-masquerade --permanent
sudo firewall-cmd --reload

modprobe br_netfilter

echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables

echo "FW Rules Added..."
