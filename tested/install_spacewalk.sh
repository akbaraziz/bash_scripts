#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/tested/
# Script date: 06/05/2020
# Script ver: 1.0.0
# Script purpose: Install Spacewalk
# Script tested on OS: CentOS 7.x
#--------------------------------------------------

set -ex

SW_VER=2.10

# Install Pre-Reqs
sudo yum install -y yum-plugin-tmprepo --quiet
sudo yum install -y spacewalk-repo --tmprepo=https://copr-be.cloud.fedoraproject.org/results/ %40spacewalkproject/spacewalk-${SW_VERSION}/epel-7-x86_64/repodata/repomd.xml --nogpg --quiet

# Install Epel repo
sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# Add Firewall Rules if Running
if [ `systemctl is-active firewalld` ]
then
    firewall-cmd --permanent --zone public --add-service http
    firewall-cmd --permanent --zone public --add-service https
    firewall-cmd --permanent --add-port=5222/tcp --add-port=5269/tcp --add-port=69/udp
    firewall-cmd --reload
else
    firewall_status=inactive
fi

# Install Spacewalk Database
sudo yum install -y spacewalk-setup-postgresql --quiet
sudo yum install -y spacewalk-postgresql --quiet

# Configure Spacewalk Message
echo "To configure Spacewalk, please run `spacewalk-setup`"