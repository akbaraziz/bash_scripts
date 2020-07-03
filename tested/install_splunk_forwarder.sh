#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script create date: 07/02/2020
# Script ver: 1.0
# Script tested on OS: CentOS 7.x
# Script purpose: Install Splunk Forwarder

#--------------------------------------------------

set -ex

SPLUNK_VER=

# Download Splunk Forwarder - Linux x64
wget -O splunkforwarder-${SPLUNK_VER}-linux-2.6-x86_64.rpm 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=7.3.1.1&product=universalforwarder&filename=splunkforwarder-7.3.1.1-7651b7244cf2-linux-2.6-x86_64.rpm&wget=true'

# Install Splunk Forwarder
sudo rpm -ivh splunkforwarder-${SPLUNK_VER}-linux-2.6-x86_64.rpm

# Start Splunk Server
sudo /opt/splunk/bin/splunk start

# Enable and Start Service
sudo /opt/splunkforwarder/bin/splunk enable boot-start
sudo systemctl start splunk