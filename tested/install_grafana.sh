#!/bin/bash
# To install Grafana on linux systems.
# Created by: Akbar Aziz
# Date: 06/05/2020
# Version: 1.0

set -ex

# Dowload the Grafana GPG Key
wget https://packages.grafana.com/gpg.key
sudo mv ./gpg.key /etc/pki/rpm-gpg/gpg.key

# Add Grafana Repository
sudo cat > /etc/yum.repos.d/grafana.repo <<EOL
[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
#gpgkey=https://packages.grafana.com/gpg.key
gpgkey=file:///etc/pki/rpm-gpg/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOL

# Install Grafana
sudo yum install -y grafana

# Add Firewall Rules if Running
if [ `systemctl is-active firewalld` ]
then
    firewall-cmd --zone=public --add-port=3000/tcp --permanent
    firewall-cmd --reload
else
    firewall_status=inactive
fi

# Enable and Start Grafana
sudo systemctl daemon-reload
sudo systemctl start grafana-server
sudo systemctl enable grafana-server.service



