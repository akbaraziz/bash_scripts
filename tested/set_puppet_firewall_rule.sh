#!/bin/bash

set -ex

# Set Puppet Firewall Rule
sudo firewall-cmd --add-port=8140/tcp --permanent
sudo firewall-cmd --reload