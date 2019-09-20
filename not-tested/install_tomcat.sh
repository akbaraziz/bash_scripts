#!/bin/bash

set -ex

# Install Pre-Reqs
sudo yum install java-1.8.0-openjdk-devel

# Create Tomcat User
sudo useradd -m -U -d /opt/tomcat -s /bin/false tomcat

# Download and Extract Tomcat
cd /tmp
wget https://www-eu.apache.org/dist/tomcat/tomcat-9/v9.0.14/bin/apache-tomcat-9.0.14.tar.gz
tar -xf apache-tomcat-9.0.14.tar.gz

# Move Source File
sudo mv apache-tomcat-9.0.14 /opt/tomcat/
sudo ln -s /opt/tomcat/apache-tomcat-9.0.14 /opt/tomcat/latest
sudo chown -R tomcat: /opt/tomcat
sudo sh -c 'chmod +x /opt/tomcat/latest/bin/*.sh'

# Create Tomcat Service
 /etc/systemd/system/tomcat.service

cat >/etc/systemd/system/tomcat.service <<EOL
[Unit]
Description=Tomcat 9 servlet container
After=network.target
[Service]
Type=forking
User=tomcat
Group=tomcat
Environment="JAVA_HOME=/usr/lib/jvm/jre"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"
Environment="CATALINA_BASE=/opt/tomcat/latest"
Environment="CATALINA_HOME=/opt/tomcat/latest"
Environment="CATALINA_PID=/opt/tomcat/latest/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"
ExecStart=/opt/tomcat/latest/bin/startup.sh
ExecStop=/opt/tomcat/latest/bin/shutdown.sh
[Install]
WantedBy=multi-user.target
EOL

# Restart System Daemon
sudo systemctl daemon-reload

# Enable and Start Tomcat Service
sudo systemctl enable tomcat
sudo systemctl start tomcat

# Firewall Rules
sudo firewall-cmd --zone=public --permanent --add-port=8080/tcpsudo
firewall-cmd --reload

# Configure Tomcat Web Management Interface
cat >/opt/tomcat/latest/conf/tomcat-users.xml <<EOL
<tomcat-users>
<!--
    Comments
-->
   <role rolename="admin-gui"/>
   <role rolename="manager-gui"/>
   <user username="admin" password="P@ssword1" roles="admin-gui,manager-gui"/>
</tomcat-users>
EOL

# Restart Tomcat Service
sudo systemctl restart tomcat