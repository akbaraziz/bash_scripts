#!/bin/bash

set -ex

# Install Java
sudo yum remove -y java
sudo yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel

# Create Cassandra Repository
cat >/etc/yum.repos.d/cassandra.repo <<EOL
[cassandra]
name=Apache Cassandra
baseurl=https://www.apache.org/dist/cassandra/redhat/311x/
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://www.apache.org/dist/cassandra/KEYS
EOL

# Install Cassandra
sudo yum install -y cassandra

# Enable and Start Cassandra
sudo systemctl enable cassandra
sudo systemctl start cassandra

# Check Status
nodetool status

