#!/bin/bash

set -ex

# Create RPM Repository
curl -sL https://bintray.com/jfrog/artifactory-rpms/rpm | sudo tee /etc/yum.repos.d/bintray-jfrog-artifactory-rpms.repo

# Install PreReqs
sudo yum -y install net-tools rsync wget

# Install Artifactory CE
sudo yum -y install jfrog-artifactory-cpp-ce

# Set Artifactory Home
echo "export ARTIFACTORY_HOME=/opt/jfrog/artifactory" | sudo tee -a /etc/profile
source /etc/profile
env | grep ARTIFACTORY_HOME