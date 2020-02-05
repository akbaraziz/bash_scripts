#!/bin/bash

set -ex

# Download Chef
wget https://packages.chef.io/stable/el/7/chef-server-core-12.10.0-1.el7.x86_64.rpm

# Install Chef
rpm -ivh chef-server-core-12.10.0-1.el7.x86_64.rpm

# Reconfigure server
chef-server-ctl reconfigure
chef-server-ctl status

# Add User 
chef-server-ctl user-create akbar Akbar Aziz akbaraziz@gmail.com P@ssword1 -f /etc/chef/admin.pem

# Create Organization
chef-server-ctl org-create home "Home Lab" --association_user akbar -f /etc/chef/home-validator.pem

# Open Firewall Ports
firewall-cmd --permanent --zone public --add-service http
firewall-cmd --permanent --zone public --add-service https
firewall-cmd --reload

