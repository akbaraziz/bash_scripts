#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script date: 06/05/2020
# Script ver: 1.0
# Script tested on OS: CentOS 7.x
# Script purpose: Install Graylog 

#--------------------------------------------------


set -ex

sudo rpm -Uvh https://packages.graylog2.org/repo/packages/graylog-2.0-repository_latest.rpm

sudo yum install -y graylog-server

sudo yum install -y epel-release

sudo yum install -y pwgen

sudo pwgen -N 1 -s 96
