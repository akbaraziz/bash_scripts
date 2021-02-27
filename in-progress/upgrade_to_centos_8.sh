#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script date: 02/24/21
# Script ver: 1.0
# Script tested on OS: CentOS 7.x
# Script purpose: Upgrade CentOS 7 Server to CentOS 8 Server

#--------------------------------------------------

set -ex

# Install Pre-Reqs
sudo yum install -y epel-release.noarch
sudo yum install -y yum-utils rpmconf
sudo package-cleanup --leaves
sudo package-cleanup --orphans

sudo yum install -y dnf

sudo dnf remove -y yum yum-metadata-parser
sudo rm -Rf /etc/yum

sudo dnf makecache

# Upgrade CentOS
sudo dnf upgrade -y
sudo dnf upgrade -y http://mirror.centos.org/centos/8/BaseOS/x86_64/os/Packages/{centos-release-8.1-1.1911.0.8.el8.x86_64.rpm,centos-gpg-keys-8.1-1.1911.0.8.el8.noarch.rpm,centos-repos-8.1-1.1911.0.8.el8.x86_64.rpm}
sudo dnf upgrade -y epel-release
sudo dnf makecache


