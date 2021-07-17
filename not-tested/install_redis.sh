#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script date: 06/28/2020
# Script ver: 1.0
# Script tested on OS: CentOS 7.x
# Script purpose: Install Redis

#--------------------------------------------------


set -ex

# Download Latest Release of Redis
curl -L http://download.redis.io/redis-stable.tar.gz -o /var/tmp/redis-stable.tar.gz

# Extract File
sudo tar zxf /var/tmp/redis-stable.tar.gz

# Compile Redis
# Check if make is installed



cd /var/tmp/redis-stable
make