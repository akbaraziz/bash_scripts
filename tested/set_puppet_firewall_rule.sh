#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/blob/master/tested/set_puppet_firewall_rule.sh
# Script date: 06/05/2020
# Script ver: 1.0.0
# Script purpose: To set firewall rules for Puppet
# Script tested on OS: CentOS and Redhat 7.x
#--------------------------------------------------

set -ex

# Set Puppet Firewall Rule
sudo firewall-cmd --add-port=8140/tcp --permanent
sudo firewall-cmd --reload