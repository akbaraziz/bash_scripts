#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/tested/install_grafana.sh
# Script date: 03/31/2021
# Script ver: 1.0.1
# Script purpose: To Install Grafana on CentOS 7 system
# Script tested on OS: CentOS 7.x
#--------------------------------------------------

set -ex

#Disable SELINUX
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

# Add Grafana Repository
sudo cat > /etc/yum.repos.d/grafana.repo <<EOL
[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
gpgkey=file:///etc/pki/rpm-gpg/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOL

# Update System
sudo yum update -y --quiet

# Install Grafana
sudo yum install -y --quiet grafana

# Install Additional Font Packages
sudo yum install -y --quiet fontconfig freetype* urw-fonts

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
sudo systemctl enable --now grafana-server

# Application Info
echo "Application URL: http://$hostname:3000"
echo "User Name: admin"
echo "Password: admin"

echo "Plugins URL: https://grafana.com/grafana/plugins?orderBy=weight&direction=asc"
