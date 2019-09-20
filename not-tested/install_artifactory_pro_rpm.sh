#!/bin/bash

set -ex

$HOST_NAME=hostname

# Download Repo
wget https://bintray.com/jfrog/artifactory-pro-rpms/rpm -O bintray-jfrog-artifactory-pro-rpms.repo
sudo mv bintray-jfrog-artifactory-pro-rpms.repo /etc/yum.repos.d/

# Install Artifactory Pro
sudo yum install jfrog-artifactory-pro

# Start Artifactory
systemctl start artifactory.service

# URL for application
echo http://$HOST_NAME:8081/artifactory

# Check Logs 
tail -f $ARTIFACTORY_HOME/logs/artifactory.log

