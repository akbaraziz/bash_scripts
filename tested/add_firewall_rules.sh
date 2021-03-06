#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/blob/master/tested/add_firewall_rules.sh
# Script date: 06/05/2020
# Script ver: 1.0.0
# Script purpose: To add firewall rules for Port 22, 80 and 443.
# Script tested on OS: CentOS and Redhat 7.x
#--------------------------------------------------

set -ex

# Allow Port 22 through firewall
sudo firewall-cmd --permanent --zone=public --add-port=22/tcp

# Allow Port 80 and 443 through firewall
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --permanent --zone=public --add-port=443/tcp

# Another Option
sudo firewall-cmd --permanent --add-service={ssh,http,https} --permanent

# Reload firewall config with new port rules
sudo firewall-cmd --reload