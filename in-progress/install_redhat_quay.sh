#!/bin/bash

set -ex

# Firewall Rules for QUAY
firewall-cmd --permanent --add-port=8443/tcp
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --reload

# Install PostgreSQL
yum install -y postgresql