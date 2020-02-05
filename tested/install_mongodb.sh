#!/bin/bash

set -ex

# Create MongoDB Repository
cat >/etc/yum.repos.d/mongodb-org-4.2.repo <<EOL
[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/7Server/mongodb-org/4.2/x86_64
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc
EOL

# Install MongoDB
sudo yum install -y mongodb-org

# Start MongoDB
sudo service mongod start

# Enable MongoDB Service
sudo chkconfig mongod on