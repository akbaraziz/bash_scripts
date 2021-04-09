#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script date: 06/05/2020
# Script ver: 1.0.0
# Script purpose: Install Apache and PHP
# Script tested on OS: CentOS 7.x
#--------------------------------------------------

set -ex

# Install Apache httpd and PhP
sudo yum update -y --quiet
sudo yum -y install epel-release --quiet
sudo rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
sudo yum install -y httpd php56w php56w-mysql --quiet

# Add Modules
echo "<IfModule mod_dir.c>
        DirectoryIndex index.php index.html index.cgi index.pl index.php index.xhtml index.htm
</IfModule>" | sudo tee /etc/httpd/conf.modules.d/dir.conf

# Create Sample PHP Info File
echo "<?php
phpinfo();
?>" | sudo tee /var/www/html/info.php

# Enable and Start httpd
sudo systemctl enable --now httpd