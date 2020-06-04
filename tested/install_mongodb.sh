#!/bin/bash

set -ex

MONGODB_VER=

# Create MongoDB Repository
cat >/etc/yum.repos.d/mongodb-org-4.2.repo <<EOL
[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/7Server/mongodb-org/${MONGODB_VER}/x86_64
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-${MONGODB_VER}.asc
EOL

# Install MongoDB
sudo yum install -y mongodb-org

# Enable and Start MongoDB
sudo service mongod start
sudo chkconfig mongod on