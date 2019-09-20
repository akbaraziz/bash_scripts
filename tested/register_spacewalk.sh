#!/bin/bash

set -ex

# Install Pre-Reqs
sudo rpm -Uvh http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum -y install rhn-client-tools rhn-check rhn-setup rhnsd m2crypto yum-rhn-plugin

# Install Spacewalk Server Certificate:
sudo rpm -Uvh http://spacewalk.lab.local/pub/rhn-org-trusted-ssl-cert-1.0-1.noarch.rpm

# Register Client with Spacewalk Server
sudo rhnreg_ks --serverUrl=https://spacewalk.lab.local/XMLRPC --sslCACert=/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT --activationkey=1-e7fed2c2d84e1329ba58462706ad39a5
sudo systemctl enable rhnsd && systemctl start rhnsd

# Disable Other External CentOS Repos
sudo sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/C*
sudo mv /etc/yum.repos.d/CentOS-Debuginfo.repo /etc/yum.repos.d/CentOS-Debuginfo.repo.orig
sudo mv /etc/yum.repos.d/CentOS-CR.repo /etc/yum.repos.d/CentOS-CR.repo.orig
sudo mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.orig
sudo mv /etc/yum.repos.d/CentOS-Sources.repo /etc/yum.repos.d/CentOS-Sources.repo.orig
sudo mv /etc/yum.repos.d/CentOS-Media.repo /etc/yum.repos.d/CentOS-Media.repo.orig
sudo mv /etc/yum.repos.d/CentOS-fasttrack.repo /etc/yum.repos.d/CentOS-fasttrack.repo.orig
sudo mv /etc/yum.repos.d/CentOS-Vault.repo /etc/yum.repos.d/CentOS-Vault.repo.orig
sudo yum clean all
sudo yum update -y