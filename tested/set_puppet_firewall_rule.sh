#!/bin/bash

set -ex

# Set Puppet Firewall Rule
firewall-cmd --add-port=8140/tcp --permanent
firewall-cmd --reload