#!/bin/bash

set -ex

# Define Variables
CHEF_VER=
CHEF_USER_NAME=
USER_FULL_NAME=
USER_EMAIL=
ORG_NAME=
CHEF_PASSWORD=

# Download Chef - CentOS 7
wget https://packages.chef.io/files/stable/chef-server/${CHEF_VER}/el/7/chef-server-core-${CHEF_VER}-1.el7.x86_64.rpm

# Install Chef
rpm -ivh chef-server-core-${CHEF_VER}-1.el7.x86_64.rpm

# Reconfigure server
chef-server-ctl reconfigure
chef-server-ctl status

# Add User 
chef-server-ctl user-create "${CHEF_USER}" "${USER_FULL_NAME}" "${USER_EMAIL}" "${CHEF_PASSWORD}" -f /etc/chef/admin.pem

# Create Organization
chef-server-ctl org-create home "${ORG_NAME}" --association_user user -f /etc/chef/home-validator.pem

# Add Firewall Rules if Running
if [ `systemctl is-active firewalld` ]
then
    firewall-cmd --permanent --zone public --add-service http
    firewall-cmd --permanent --zone public --add-service https
    firewall-cmd --reload
else
    firewall_status=inactive
fi


