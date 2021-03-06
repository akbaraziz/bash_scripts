#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/tested/install_tomcat.sh
# Script date: 06/05/2020
# Script ver: 1.0.0
# Script purpose: Install Tomcat
# Script tested on OS: CentOS 7.x
#--------------------------------------------------

set -ex

TOMCAT_VER=9.0.35
TOMCAT_ADMIN_PASSWORD=

# Remove Existing Version of Java if installed
if rpm -qa | grep -q java*; then
    yum remove -y java*;
else
    echo Not Installed
fi

# Install Pre-Reqs
sudo yum install java-1.8.0-openjdk --quiet

# Create Tomcat User
sudo useradd -m -U -d /opt/tomcat -s /bin/false tomcat

# Download and Extract Tomcat
cd /var/tmp
wget http://www.gtlib.gatech.edu/pub/apache/tomcat/tomcat-9/v${TOMCAT_VER}/bin/apache-tomcat-${TOMCAT_VER}.zip
tar -xf apache-tomcat-${TOMCAT_VER}.tar.gz

# Move Source File
sudo mkdir -p /opt/tomcat/latest/bin
sudo mv apache-tomcat-${TOMCAT_VER} /opt/tomcat/
sudo ln -s /opt/tomcat/apache-tomcat-${TOMCAT_VER} /opt/tomcat/latest

# Configure Tomcat Web Management Interface
sudo cat >/opt/tomcat/latest/conf/tomcat-users.xml <<EOL
<tomcat-users>
<!--
    Comments
-->
   <role rolename="admin-gui"/>
   <role rolename="manager-gui"/>
   <user username="admin" password="${TOMCAT_ADMIN_PASSWORD}" roles="admin-gui,manager-gui"/>
</tomcat-users>
EOL

sudo chown -R tomcat: /opt/tomcat
sudo sh -c 'chmod +x /opt/tomcat/latest/bin/*.sh'

sudo cat >/etc/systemd/system/tomcat.service <<EOL
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
sudo systemctl enable --now tomcat

# Add Firewall Rules if Running
if [ `systemctl is-active firewalld` ]
then
    firewall-cmd --zone=public --permanent --add-port=8080/tcp
    firewall-cmd --reload
else
    firewall_status=inactive
fi

# Tomcat URL
echo "Application URL is http://`hostname`:8080"
