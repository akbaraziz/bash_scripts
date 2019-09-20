#!/bin/bash

set -ex

# Configure Firewall Rules
sudo systemctl start firewalld
sudo systemctl enable firewalld
firewall-cmd --add-port=8000/tcp --add-port=8089/tcp --add-port=8191/tcp --add-port=8065/tcp --add-port=9997/tcp
firewall-cmd --zone=public --add-service=syslog --add-service=syslog-tls –-permanent
firewall-cmd --reload

# Download Splunk Server - Linux x64
wget -O splunk-7.3.1.1-7651b7244cf2-linux-2.6-x86_64.rpm 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=7.3.1.1&product=splunk&filename=splunk-7.3.1.1-7651b7244cf2-linux-2.6-x86_64.rpm&wget=true'

# Download Splunk Forwarder - Linux x64
wget -O splunkforwarder-7.3.1.1-7651b7244cf2-linux-2.6-x86_64.rpm 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=7.3.1.1&product=universalforwarder&filename=splunkforwarder-7.3.1.1-7651b7244cf2-linux-2.6-x86_64.rpm&wget=true'

# Install Splunk Server
sudo rpm -ivh splunk-7.3.1.1-7651b7244cf2-linux-2.6-x86_64.rpm

# Start Splunk Server
sudo /opt/splunk/bin/splunk start

# Enable Splunk Service to start on boot
sudo /opt/splunk/bin/splunk enable boot-start

# URL for application
echo "http://$HOSTNAME:8000"
