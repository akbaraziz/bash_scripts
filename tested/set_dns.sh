#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/blob/master/tested/add_firewall_rules.sh
# Script date: 06/05/2020
# Script ver: 1.0.0
# Script purpose: To set DNS Servers using NetworkManager.
# Script tested on OS: CentOS and Redhat 7.x
#--------------------------------------------------

set -ex

IP1=10.10.10.7
IP2=10.10.10.5
IP3=192.168.1.1

sudo nmcli con mod eth0 ipv4.dns "$IP1,$IP2,$IP3"
sudo nmcli connection reload