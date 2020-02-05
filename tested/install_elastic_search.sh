#!/bin/bash

set -ex

# Create Elastic Search Repository
sudo rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch

cat >/etc/yum.repos.d/elasticsearch.repo <<EOL
[elasticsearch]
name=Elasticsearch repository
baseurl=https://packages.elastic.co/elasticsearch/2.x/centos
gpgcheck=1
gpgkey=https://packages.elastic.co/GPG-KEY-elasticsearch
enabled=1
EOL

# Install Elastic Search
sudo yum -y install elasticsearch

# Restart Daemon Service
sudo systemctl daemon-reload

# Enable Elastic Search Service
sudo systemctl enable elasticsearch