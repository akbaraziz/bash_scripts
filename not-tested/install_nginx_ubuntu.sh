
apt-get install -y nginx apache2-utils >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install nginx (Error Code: $ERROR)."
    fi
    
echo "[HELK INFO] Adding a user ' $nginxUsername '::' $passvar1 'htpasswd.users file to nginx.."
htpasswd -b -c /etc/nginx/htpasswd.users $nginxUsername $passvar1 >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not add user Hunter to htpasswd.users file (Error Code: $ERROR)."
    fi
    
echo "[HELK INFO] Backing up Nginx's config file.."
cp /etc/nginx/sites-available/default /etc/nginx/sites-available/backup_default >> $LOGFILE 2>&1
sudo truncate -s 0 /etc/nginx/sites-available/default >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not create a backup of nginx config file (Error Code: $ERROR)."
    fi
    
echo "[HELK INFO] Creating custom nginx config file to /etc/nginx/sites-available/default.."

HOSTIPADDR=$(ifconfig | awk '/inet/{print substr($2,1)}'| head -n 1)

newDefault="
    server {
        listen 80 default_server; # Listen on port 80
        server_name ""$HOSTIPADDR""; # Bind to the IP address of the server
        return         301 https://\$server_name\$request_uri; # Redirect to 443/SSL
   }
    server {
        listen 443 default ssl; # Listen on 443/SSL
        # SSL Certificate, Key and Settings
        ssl_certificate /etc/pki/tls/certs/ELK-Stack.crt ;
        ssl_certificate_key /etc/pki/tls/private/ELK-Stack.key;
        ssl_session_cache shared:SSL:10m;
        # Basic authentication using the account created with htpasswd
        auth_basic \"Restricted Access\";
        auth_basic_user_file /etc/nginx/htpasswd.users;
        location / {
     # Proxy settings pointing to the Kibana instance
            proxy_pass http://localhost:5601;
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host \$host;
            proxy_cache_bypass \$http_upgrade;
        }
    }
"
echo "$newDefault" >> /etc/nginx/sites-available/default

ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not create custom nginx file (Error Code: $ERROR)."
    fi
    
echo "[HELK INFO] testing nginx configuration.."
nginx -t >> $LOGFILE 2>&1

echo "[HELK INFO] Restarting nginx service.."
systemctl restart nginx >> $LOGFILE 2>&1
ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not restart nginx (Error Code: $ERROR)."
    fi