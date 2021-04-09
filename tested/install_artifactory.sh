#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/blob/master/tested/install_artifactory.sh
# Script date: 06/05/2020
# Script ver: 1.0.0
# Script purpose: To install JFrog Artifactory COmmunity Edition
# Script tested on OS: CentOS and Redhat 7.x
#--------------------------------------------------

set -ex

# Create RPM Repository
curl -sL https://bintray.com/jfrog/artifactory-rpms/rpm | sudo tee /etc/yum.repos.d/bintray-jfrog-artifactory-rpms.repo

# Install PreReqs
sudo yum -y install net-tools rsync wget --quiet

# Install Artifactory CE
sudo yum -y install jfrog-artifactory-cpp-ce --quiet

# Set Artifactory Home
echo "export ARTIFACTORY_HOME=/opt/jfrog/artifactory" | sudo tee -a /etc/profile
source /etc/profile
env | grep ARTIFACTORY_HOME