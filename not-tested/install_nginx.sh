#!/bin/bash
# Remember to enter DOMAIN value in Script

set -ex

# Create NGINX Red Hat 7 Repository
cat > /etc/yum.repos.d/nginx.repo <<EOL
#[nginx]
#name=nginx repo
#baseurl=http://nginx.org/packages/rhel/$releasever/$basearch/
#gpgcheck=0
#enabled=1
#EOL

# Create NGINX CentOS 7 Repository
#cat >/etc/yum.repos.d/nginx.repo <<EOL
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/7/$basearch/
gpgcheck=0
enabled=1
EOL

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