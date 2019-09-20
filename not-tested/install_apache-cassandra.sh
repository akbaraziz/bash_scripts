#!/bin/bash

set -ex

# Install Java
sudo yum remove java -y
sudo yum install java-1.8.0-openjdk-devel

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
sudo yum install cassandra

# Enable and Start Cassandra
sudo systemctl enable cassandra
sudo systemctl start cassandra

# Check Status
nodetool status

