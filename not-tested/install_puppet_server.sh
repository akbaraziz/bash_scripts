#!/bin/bash

set -ex
PUPPET_VER=2019.8.4
HOST_NAME=
IPADDR=@@{address}@@

# Download Puppet Enterprise Server
# CENTOS/RHEL 8
wget --content-disposition 'https://pm.puppet.com/cgi-bin/download.cgi?dist=el&rel=8&arch=x86_64&ver=latest'

# CENTOS/RHEL 7
#wget --content-disposition 'https://pm.puppet.com/cgi-bin/download.cgi?dist=el&rel=7&arch=x86_64&ver=latest'

# UBUNTU 18.04
#wget --content-disposition 'https://pm.puppet.com/cgi-bin/download.cgi?dist=ubuntu&rel=18.04&arch=amd64&ver=latest'

# Extract Puppet File
tar -xf puppet-enterprise-${PUPPET_VER}-el-8-x86_64.tar.gz

# Install Puppet Server
cd puppet-enterprise-${PUPPET_VER}-el-8-x86_64
./puppet-enterprise-installer

# Set Puppet Console Password
puppet infrastructure console_password --password=@@{PUPPET_PASSWD}@@

# Run Puppet Agent Twice
puppet agent -t
puppet agent -t

# Add Firewall Rules
sudo firewall-cmd --permanent --zone=public --add-port=443/tcp
sudo firewall-cmd --permanent --zone=public --add-port=3000/tcp
sudo firewall-cmd --reload

# Update Local Hosts File
sudo echo ${HOST_NAME} | tee /etc/hostname
sudo sed -i -E 's/^127.0.1.1.*/127.0.1.1\t'"${HOST_NAME}"'/' /etc/hosts
sudo sed -i -E 's/^127.0.1.1.*/127.0.1.1\t'"${HOST_NAME}"'/' /etc/sysconfig/network
sudo echo -e ""${IPADDR}" \t "${HOST_NAME}"" >> /etc/hosts
