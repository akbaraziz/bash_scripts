#!/bin/bash

set -ex

$HOST_NAME=hostname

# Install Java
sudo yum remove -y java
sudo yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel

# Download Repo
wget https://bintray.com/jfrog/artifactory-pro-rpms/rpm -O bintray-jfrog-artifactory-pro-rpms.repo
sudo mv bintray-jfrog-artifactory-pro-rpms.repo /etc/yum.repos.d/

# Install Artifactory Pro
sudo yum install -y jfrog-artifactory-pro

# Start Artifactory
systemctl start artifactory.service

# URL for application
echo http://$HOST_NAME:8081/artifactory

# Check Logs 
tail -f $ARTIFACTORY_HOME/logs/artifactory.log

