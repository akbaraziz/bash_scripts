#!/bin/bash

set -ex

SPLUNK_USER=@@{SPLUNK_USER}@@

# Check if wget is installed
rpm -qa | grep -qw wget || yum install -y wget

# Download Splunk Enterprise
wget -O splunk-8.1.1-08187535c166-linux-2.6-x86_64.rpm 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.1.1&product=splunk&filename=splunk-8.1.1-08187535c166-linux-2.6-x86_64.rpm&wget=true'

# Enable Execution of RPM
chmod +x splunk-8.1.1-08187535c166-linux-2.6-x86_64.rpm

# Install Splunk
rpm -i splunk-8.1.1-08187535c166-linux-2.6-x86_64.rpm

# Start Splunk on Boot
sudo $SPLUNK_HOME/bin/splunk enable boot-start -user ${SPLUNK_USER}

# Change Ownership of Splunk Files
sudo chown -R ${SPLUNK_USER} $SPLUNK_HOME


