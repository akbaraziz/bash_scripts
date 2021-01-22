#!/bin/bash

set -ex
PUPPET_VERSION=@@{PUPPET_VER}@@
HOST_NAME=@@{HOST_NAME}@@
IPADDR=@@{address}@@

# Disable SELinux
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

# Update Local Hosts File
sudo echo ${HOST_NAME} | tee /etc/hostname
sudo sed -i -E 's/^127.0.1.1.*/127.0.1.1\t'"${HOST_NAME}"'/' /etc/hosts
sudo sed -i -E 's/^127.0.1.1.*/127.0.1.1\t'"${HOST_NAME}"'/' /etc/sysconfig/network
sudo echo -e ""${IPADDR}" \t "${HOST_NAME}"" >> /etc/hosts
sudo systemctl restart systemd-hostnamed

# Add Firewall Rules
if [ `systemctl is-active firewalld` ]
then
    sudo firewall-cmd --permanent --add-port=443/tcp
    sudo firewall-cmd --permanent --add-port=8140/tcp
    sudo firewall-cmd --reload
else
    firewall_status=inactive
fi

# Configure Chrony
sudo echo "
server 0.us.pool.ntp.org iburst
server 1.us.pool.ntp.org iburst
server 2.us.pool.ntp.org iburst" | sudo tee -a /etc/chrony.conf
sudo timedatectl set-timezone America/Chicago --adjust-system-clock
sudo systemctl enable --now chronyd
sudo timedatectl set-ntp yes

# Download and Install Puppet Enterprise Server
# CENTOS/RHEL 8
sudo dnf update
sudo dnf -y install wget curl chrony bash-completion
rpm -ivh https://yum.puppet.com/puppet6-release-el-8.noarch.rpm
sudo dnf clean all
yum install -y puppetserver
export PATH=$PATH:/opt/puppetlabs/bin

# Configure Puppet Server
cat > /etc/puppetlabs/puppet/puppet.conf <<EOL
[main]
certname = @@{HOST_NAME}@@
server = @@{HOST_NAME}@@
user = pe-puppet
group = pe-puppet
environment = production
environment_timeout = 0
module_groups = base+pe_only
autosign = true

[agent]
graph = true
server_list = @@{HOST_NAME}@@:8140

[master]
node_terminus = classifier
storeconfigs = true
storeconfigs_backend = puppetdb
reports = puppetdb
certname = @@{HOST_NAME}@@
always_retry_plugins = false
disable_i18n = false
versioned_environment_dirs = true
EOL

# Generate Puppet CA Certificate
sudo /opt/puppetlabs/bin/puppetserver ca setup

# Set Puppet Console Password
sudo /opt/puppetlabs/bin/puppet infrastructure console_password --password=@@{PuppetAdmin.secret}@@

# Check if running latest version of Puppet
sudo /opt/puppetlabs/bin/puppet resource package puppetserver ensure=latest
# Start Puppet Server
systemctl enable --now puppetserver