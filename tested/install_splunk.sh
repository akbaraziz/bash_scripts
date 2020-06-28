#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script date: 06/05/2020
# Script ver: 1.0
# Script tested on OS: CentOS 7.x
# Script purpose: Install Splunk

#--------------------------------------------------


set -ex

SPLUNK_VER=8.0.4-767223ac207f
PLATFORM_VER=8.0.4

# Disable SELINUX
setenforce 0
sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config

# Download Splunk Server - Linux x64
wget -O splunk-${SPLUNK_VER}-linux-2.6-x86_64.rpm 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=${PLATFORM_VER}&product=splunk&filename=splunk-${SPLUNK_VER}-linux-2.6-x86_64.rpm&wget=true'

# Download Splunk Forwarder - Linux x64
wget -O splunkforwarder-${SPLUNK_VER}-linux-2.6-x86_64.rpm 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=${PLATFORM_VER}&product=universalforwarder&filename=splunkforwarder-${SPLUNK_VER}-linux-2.6-x86_64.rpm&wget=true'

# Install Splunk Server
sudo rpm -ivh splunk-${SPLUNK_VER}-linux-2.6-x86_64.rpm

# Enable and Start Splunk Server
sudo /opt/splunk/bin/splunk start
sudo /opt/splunk/bin/splunk enable boot-start

# Add Firewall Rules if Running
if [ `systemctl is-active firewalld` ]
then
    firewall-cmd --add-port=8000/tcp --add-port=8089/tcp --add-port=8191/tcp --add-port=8065/tcp --add-port=9997/tcp
    firewall-cmd --zone=public --add-service=syslog --add-service=syslog-tls –-permanent
    firewall-cmd --reload
else
    firewall_status=inactive
fi

# URL for application
echo "http://$HOSTNAME:8000"
