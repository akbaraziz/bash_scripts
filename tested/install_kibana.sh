#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script date: 12/09/2020
# Script ver: 1.0
# Script tested on OS: CentOS 7.x
# Script purpose: To install Kibana

#--------------------------------------------------

set -ex

# Import ElasticSearch PGP Key
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

# Create RPM Repository
cat >/etc/yum.repos.d/kibana.repo <<EOL 
[kibana-7.x]
name=Kibana repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOL


# Install Kabana
sudo yum -y  install kibana

# Add Firewall Rules
sudo firewall-cmd --new-zone=kabana --permanent
sudo firewall-cmd --reload
sudo firewall-cmd --zone=kabana --add-source=@@{address}@@/32 --permanent
sudo firewall-cmd --zone=kabana --add-port=5601/tcp --permanent
sudo firewall-cmd --reload

# Start and Enable Kibana
sudo systemctl enable --now kibana