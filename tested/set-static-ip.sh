#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/tested/set-static-ip.sh
# Script create date: 07/02/2020
# Script ver: 1.0.0
# Script purpose: Set Static IP Address on Server
# Script tested on OS: CentOS 7.x
#--------------------------------------------------

set -ex

# Set IP Address and Gateway
sudo nmcli con mod eth0 ipv4.addresses @@{IP_ADDRESS}@@/@@{CIDR}@@ ipv4.gateway @@{GATEWAY}@@ ipv4.method manual
#sudo nmcli con up eth0