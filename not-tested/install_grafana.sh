#!/bin/bash

set -ex

#Dowload the GPG Key
wget https://packages.grafana.com/gpg.key
sudo mv ./gpg.key /etc/pki/rpm-gpg/gpg.key

#Adding Grafana Repository
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

#Install Grafana
sudo yum install grafana -y

#Starting Grafana
sudo systemctl daemon-reload
sudo systemctl start grafana-server

#Enable Service to Start on Boot
sudo systemctl enable grafana-server.service

if [ `systemctl is-active firewalld` ]
then
    firewall-cmd --zone=public --add-port=3000/tcp --permanent && firewall-cmd --reload
else
    firewall_status=inactive
fi

