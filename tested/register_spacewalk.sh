#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script create date: 07/02/2020
# Script ver: 1.0
# Script tested on OS: CentOS 7.x
# Script purpose: Register with Spacewalk Server
#--------------------------------------------------

set -ex

SW_HOSTNAME=
KEY=

# Add EPEL Repo
sudo rpm -Uvh http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# Install Pre-Reqs
sudo yum -y install rhn-client-tools rhn-check rhn-setup rhnsd m2crypto yum-rhn-plugin --quiet

# Install Spacewalk Server Certificate:
sudo rpm -Uvh http://${SW_HOSTNAME}/pub/rhn-org-trusted-ssl-cert-1.0-1.noarch.rpm

# Register Client with Spacewalk Server
sudo rhnreg_ks --serverUrl=https://${SW_HOSTNAME}/XMLRPC --sslCACert=/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT --activationkey=${KEY}
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
sudo yum update -y --quiet