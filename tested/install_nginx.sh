#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script date: 07/02/2020
# Script ver: 1.0.1
# Script purpose: Install NGINX
# Script tested on OS: CentOS 7.x
#--------------------------------------------------

set -ex

DOMAIN=

# Create NGINX Red Hat 7 Repository
cat > /etc/yum.repos.d/nginx.repo <<EOL
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/mainline/rhel/7/$basearch/
gpgcheck=0
enabled=1
EOL

# Create NGINX CentOS 7 Repository
#cat >/etc/yum.repos.d/nginx.repo <<EOL
#[nginx]
#name=nginx repo
#baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
#gpgcheck=0
#enabled=1
#EOL

# Install NGINX
yum install -y nginx --quiet

# Enable and Start NGINX Service
systemctl enable --now nginx

# Configure NGINX
mkdir -p /var/www/$DOMAIN
mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.disabled
cat > /etc/nginx/conf.d/$DOMAIN.conf <<EOL
server {
    listen         80 default_server;
    listen         [::]:80 default_server;
    server_name    $DOMAIN.com www.$DOMAIN.com;
    root           /var/www/$DOMAIN.com;
    index          index.html;

    location / {
      try_files $uri $uri/ =404;
    }
}
EOL

# Add Firewall Rules if Running
if [ `systemctl is-active firewalld` ]
then
    firewall-cmd --permanent --zone public --add-service http
    firewall-cmd --reload
else
    firewall_status=inactive
fi

nginx -s reload