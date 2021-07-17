#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/tested/install_rabbitmq.sh
# Script date: 05/05/2021
# Script ver: 1.0.0
# Script purpose: Install LAMP
# Script tested on OS: CentOS 8.x
#--------------------------------------------------

set -ex

# Disable SELinux
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

# Add Repos
sudo dnf install -y --quiet epel-release
sudo rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

# Install Apache HTTPD Server
sudo dnf install -y --quiet httpd 

# Start and Enable Apache HTTPD Server
sudo systemctl enable --now httpd

# Install MySQL
sudo dnf install -y --quiet @mysql 

# Start and Enable MySQL Server
sudo systemctl enable --now mysql 

# Install PhP
sudo dnf install -y --quiet dnf-utils http://rpms.remirepo.net/enterprise/remi-release-8.rpm
sudo dnf module reset php
sudo dnf module enable php:remi-7.4

# Install PhP Modules
sudo dnf install -y --quiet php php-opcache php-gd php-curl php-mysqlnd

# Configure PhP
chown -R apache:apache /var/www
sudo sed -i '/<Directory \/>/,/<\/Directory/{//!d}' /etc/httpd/conf/httpd.conf
sudo sed -i '/<Directory \/>/a\    Options Indexes FollowSymLinks\n    AllowOverride All\n    Require all granted' /etc/httpd/conf/httpd.conf

# Modify Firewall Rules
if [ "$(systemctl is-active firewalld)" ]
then
    sudo firewall-cmd --permanent --add-service=http
    sudo firewall-cmd --permanent --add-service=https
    sudo firewall-cmd --permanent --add-port=80/tcp
    sudo firewall-cmd --permanent --add-port=443/tcp
    sudo firewall-cmd --reload
else
    echo "Firewall is not running"
fi

# Modify PhP File
echo "<?php
phpinfo();
?>" | sudo tee /var/www/html/info.php 

# Start and Enable PhP Service
sudo systemctl enable --now php-fpm

# Restart Apache HTTPD Service
sudo systemctl restart httpd