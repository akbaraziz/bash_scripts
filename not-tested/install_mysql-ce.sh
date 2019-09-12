#!/bin/bash

set -ex

# Create MySQL Community Edition Repository
rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm

# Install OpenJDK 8
yum install -y java-1.8.0-OpenJDK

# Set JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-OpenJDK
export PATH=$JAVA_HOME:$PATH

# Install MySQL 8 Community Edition
yum install -y mysql-community-server

./sbin/chkconfig --levels 345 mysqld on 

# Changing default authentication settings
cat >/etc/my.cnf <<EOL
[mysqld]
default-authentication-plugin=mysql_native_password
EOL
