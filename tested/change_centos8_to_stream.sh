#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/blob/master/tested/change_centos8_to_stream.sh
# Script date: 03/05/2021
# Script ver: 1.0.0
# Script purpose: To switch CentOS 8 version to Stream
# Script tested on OS: CentOS 8.x
#--------------------------------------------------

set -ex

# Build Cache for Yum Repository
sudo dnf makecache

# Install CentOS-Stream Package
sudo dnf install -y centos-release-stream

# Replace CentOS to Stream
sudo dnf swap -y centos-{linux,stream}-repos

# Sync Repo
sudo dnf -y distro-sync