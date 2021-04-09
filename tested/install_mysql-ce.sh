#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script date: 06/05/2020
# Script ver: 1.0.0
# Script purpose: Install MySQL Community Edition
# Script tested on CentOS 7.x
#--------------------------------------------------

set -ex

MYSQL_VER=

# Create MySQL Community Edition Repository
rpm -Uvh https://dev.mysql.com/get/mysql-community-server-${MYSQL_VER}.el7.x86_64.rpm

# Remove Existing Version of Java if installed
if rpm -qa | grep -q java*; then
    yum remove -y java*;
else
    echo Not Installed
fi

# Install OpenJDK 8
sudo yum install -y java-1.8.0-openjdk --quiet

# Set JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk
export PATH=$JAVA_HOME:$PATH

# Install MySQL 8 Community Edition
yum install -y mysql-community-server --quiet

# Enable and Start MySQL Service
systemctl enable --now mysqld.service

# Get the temporary password
cat| grep 'temporary password' /var/log/mysqld.log

# Changing default authentication settings
cat >/etc/my.cnf <<EOL
[mysqld]
default-authentication-plugin=mysql_native_password
EOL
