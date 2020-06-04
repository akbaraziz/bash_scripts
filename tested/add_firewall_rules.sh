#!/bin/bash

set -ex

# Allow Port 22 through firewall
sudo firewall-cmd --permanent --zone=public --add-port=22/tcp

# Allow Port 80 and 443 through firewall
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --permanent --zone=public --add-port=443/tcp

# Reload firewall config with new port rules
sudo firewall-cmd --reload