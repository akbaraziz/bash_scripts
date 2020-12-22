#!/bin/bash

set -ex

# Download Octopus Repo
wget https://rpm.octopus.com/tentacle.repo -O /etc/yum.repos.d/tentacle.repo

# Install Octopus Tentacle
sudo yum install -y tentacle