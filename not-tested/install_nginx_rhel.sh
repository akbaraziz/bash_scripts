#!/bin/bash
# Remember to enter DOMAIN value in Script

set -ex

# Create NGINX RHEL 7 Repository
rpm -ivh http://nginx.org/packages/rhel/7/noarch/RPMS/nginx-release-rhel-7-0.el7.ngx.noarch.rpm

# Install NGINX
yum install -y nginx

# Start NGINX Service
systemctl start nginx 

# Enable NGINX Service
systemctl enable NGINX

DOMAIN=test

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

nginx -s reload