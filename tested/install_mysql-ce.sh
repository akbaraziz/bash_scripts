#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script date: 06/05/2020
# Script ver: 1.0
# Script tested on OS: CentOS 7.x
# Script purpose: Install MySQL Community Edition

#--------------------------------------------------


set -ex

MYSQL_VER=

# Create MySQL Community Edition Repository
rpm -Uvh https://dev.mysql.com/get/mysql-community-server-${MYSQL_VER}.el7.x86_64.rpm


# Install OpenJDK 8
sudo yum install -y java-1.8.0-openjdk

# Set JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk
export PATH=$JAVA_HOME:$PATH

# Install MySQL 8 Community Edition
yum install -y mysql-community-server

# Enable and Start MySQL Service
systemctl enable mysqld.service
systemctl start mysqld.service

# Get the temporary password
cat| grep 'temporary password' /var/log/mysqld.log 

# Changing default authentication settings
cat >/etc/my.cnf <<EOL
[mysqld]
default-authentication-plugin=mysql_native_password
EOL
