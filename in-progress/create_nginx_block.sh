#!/usr/bin/env bash
#
# Nginx - new server block

# Functions
ok() { echo -e '\e[32m'$1'\e[m'; } # Green
die() { echo -e '\e[1;31m'$1'\e[m'; exit 1; }

# Variables
NGINX_AVAILABLE_VHOSTS='/etc/nginx/sites-available'
NGINX_ENABLED_VHOSTS='/etc/nginx/sites-enabled'
WEB_DIR='/var/www'
WEB_USER='www-data'
USER='yourusername'
NGINX_SCHEME='$scheme'
NGINX_REQUEST_URI='$request_uri'

# Sanity check
[ $(id -g) != "0" ] && die "Script must be run as root."
[ $# != "1" ] && die "Usage: $(basename $0) domainName"

# Create nginx config file
cat > $NGINX_AVAILABLE_VHOSTS/$1 <<EOF
# www to non-www
server {
    # If user goes to www direc them to non www
    server_name *.$1;
    return 301 $NGINX_SCHEME://$1$NGINX_REQUEST_URI;
}
server {
    # Just the server name
    server_name $1;
    root        /var/www/$1/public_html;

    # Logs
    access_log $WEB_DIR/$1/logs/access.log;
    error_log  $WEB_DIR/$1/logs/error.log;

    # Includes
    include global/common.conf;
    include global/wordpress.conf;

    # Listen to port 8080, cause of Varnis
    # Must be defined after the common.conf include
    #listen 127.0.0.1:8080;
}
EOF

# Creating {public,log} directories
mkdir -p $WEB_DIR/$1/{public_html,logs}

# Creating index.html file
cat > $WEB_DIR/$1/public_html/index.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
        <title>$1</title>
        <meta charset="utf-8" />
</head>
<body class="container">
        <header><h1>$1<h1></header>
        <div id="wrapper">

Hello World
</div>
        <footer>© $(date +%Y)</footer>
</body>
</html>
EOF

# Changing permissions
chown -R $USER:$WEB_USER $WEB_DIR/$1

# Enable site by creating symbolic link
ln -s $NGINX_AVAILABLE_VHOSTS/$1 $NGINX_ENABLED_VHOSTS/$1

# Restart
echo "Do you wish to restart nginx?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) /etc/init.d/nginx restart ; break;;
        No ) exit;;
    esac
done

ok "Site Created for $1"