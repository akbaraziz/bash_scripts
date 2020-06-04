#!/bin/bash

set -ex

# Download Splunk Forwarder - Linux x64
wget -O splunkforwarder-7.3.1.1-7651b7244cf2-linux-2.6-x86_64.rpm 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=7.3.1.1&product=universalforwarder&filename=splunkforwarder-7.3.1.1-7651b7244cf2-linux-2.6-x86_64.rpm&wget=true'

# Install Splunk Forwarder
sudo rpm -ivh splunkforwarder-7.3.1.1-7651b7244cf2-linux-2.6-x86_64.rpm

# Start Splunk Server
sudo /opt/splunk/bin/splunk start

# Enable and Start Service
sudo /opt/splunkforwarder/bin/splunk enable boot-start
sudo systemctl start splunk

# URL for application
echo https://splunk.lab.local:8000