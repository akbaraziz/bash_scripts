#!/bin/bash


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