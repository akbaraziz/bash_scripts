#!/bin/bash
# To install Elastic Search on CentOS and Redhat 7 systems.
# Created by: Akbar Aziz
# Date: 06/05/2020
# Version: 1.0

set -ex

# Create Elastic Search Repository
sudo rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch

cat >/etc/yum.repos.d/elasticsearch.repo <<EOL
[elasticsearch]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=0
autorefresh=1
type=rpm-md
EOL

sudo yum install --enablerepo=elasticsearch elasticsearch
# Install Elastic Search
sudo yum -y install elasticsearch

# Start Elasticsearch
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable elasticsearch.service

