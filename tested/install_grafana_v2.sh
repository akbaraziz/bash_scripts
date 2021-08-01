#!/bin/bash

set -ex

# Set Firewall Rules
if [ "$(systemctl is-active firewalld)" ]
then
    sudo firewall-cmd --zone=public --permanent --add-port=3000/tcp
    sudo firewall-cmd --reload
else
    echo "Firewall is not running"
fi

# Configure SELinux
selinuxenabled
if [ $? -ne 0 ]
then 
    echo "SELINUX is DISABLED"
else
    sudo setsebool -P nis_enabled 1
fi

# Create Grafana Repo
echo '
[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt' | sudo tee -a /etc/yum.repos.d/grafana.repo

# Install Grafana
sudo yum install grafana -y

# Start and Enable Grafana Service
sudo systemctl daemon-reload
sudo systemctl enable --now grafana-server

# Application Info
echo "Application URL: http://$hostname:3000"
echo "User Name: admin"
echo "Password: admin"

echo "Plugins URL: https://grafana.com/grafana/plugins?orderBy=weight&direction=asc"

