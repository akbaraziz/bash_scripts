#!/bin/bash

set -ex

# Install Pre-Reqs
yum install -y yum-plugin-tmprepo
yum install -y spacewalk-repo --tmprepo=https://copr-be.cloud.fedoraproject.org/results/%40spacewalkproject/spacewalk-2.9/epel-7-x86_64/repodata/repomd.xml --nogpg

# Install Epel repo
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# Create/Modify Firewall Rules
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-port=5222/tcp --add-port=5269/tcp --add-port=69/udp
firewall-cmd --reload

# Install Spacewalk Database
yum install -y spacewalk-setup-postgresql
yum install -y spacewalk-postgresql

# Configure Spacewalk
spacewalk-setup