#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/blob/master/tested/configre_rsyslog_server.sh
# Script date: 06/05/2020
# Script ver: 1.0.0
# Script purpose: Check rsyslog server
# Script tested on OS: CentOS and Redhat 7.x
#--------------------------------------------------

set -ex

STATUS="$(systemctl is-active rsyslog.service)"
if [ "${STATUS}" = "active" ]; then
    echo "Service is running..."
else
    echo "Service is not running ..."
fi

# Enable Syslog Listener
sudo sed -i '/ModLoad imtcp/s/^#//g' /etc/rsyslog.conf
sudo sed -i '/InputTCPServerRun/s/^#//g' /etc/rsyslog.conf

# Restart Syslog Service
sudo systemctl restart rsyslog.service

# Add firewall rule for Syslog Service
sudo firewall-cmd --permanent --add-port=514/tcp
sudo firewall-cmd --reload