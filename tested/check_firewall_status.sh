#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script create date: 07/02/2020
# Script ver: 1.0
# Script tested on OS: CentOS 7.x
# Script purpose: Check Firewall Status

#--------------------------------------------------

set -ex

if [ `systemctl is-active firewalld` ]
then
    firewall_status=active
else
    firewall_status=inactive
fi