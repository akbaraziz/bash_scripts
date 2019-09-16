#!/bin/bash

set -ex

# Create MySQL Community Edition Repository
rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm

# Install OpenJDK 8
yum install java-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64

# Set JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64
export PATH=$JAVA_HOME:$PATH

# Install MySQL 8 Community Edition
yum install -y mysql-community-server

systemctl enable mysqld.service
systemctl start mysqld.service 

# Changing default authentication settings
cat >/etc/my.cnf <<EOL
[mysqld]
default-authentication-plugin=mysql_native_password
EOL
