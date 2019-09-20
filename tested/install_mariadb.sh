#!/bin/bash

set -ex

# Create MariaDB Repository
cat >/etc/yum.repos.d/MariaDB.repo <<EOL
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.3/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=0
enabled=1
EOL

# Install MariaDB and Components
sudo yum install -y MariaDB-server galera MariaDB-client MariaDB-shared MariaDB-backup MariaDB-common

# Start MariaDB
sudo systemctl start mariadb

# Enable MariaDb Service
sudo systemctl enable mariadb

# Secure MariaDB Installation
sudo mysql_secure_installation