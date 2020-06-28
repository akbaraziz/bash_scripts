#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script date: 06/05/2020
# Script ver: 1.0
# Script tested on OS: CentOS 7.x
# Script purpose: Install MariaDB

#--------------------------------------------------


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

# Enable and Start MariaDB
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Secure MariaDB Installation
sudo mysql_secure_installation