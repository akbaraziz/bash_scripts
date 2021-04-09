#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/blob/master/tested/check_firewall_status.sh
# Script date: 06/05/2020
# Script ver: 1.0.0
# Script purpose: To check if Firewalld Service is running
# Script tested on OS: CentOS and Redhat 7.x
#--------------------------------------------------

set -ex

if [ "$(systemctl is-active firewalld)" ]
then
    firewall_status=active
else
    echo "Firewall is not running"
fi