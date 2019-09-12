#!/bin/bash

set -ex

# Create MariaDB Repository
cat >/etc/yum.repos.d/MariaDB.repo <<EOL
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.3/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOL

# Install MariaDB and Components
sudo yum install MariaDB-server galera MariaDB-client MariaDB-shared MariaDB-backup MariaDB-common

# Start MariaDB
systemctl start mariadb

# Enable MariaDb Service
systemctl enable mariadb

# Secure MariaDB Installation
mysql_secure_installation