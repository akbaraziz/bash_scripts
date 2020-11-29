#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script date: 06/05/2020
# Script ver: 1.0
# Script tested on OS: CentOS 7.x
# Script purpose: Disable SELinux

#--------------------------------------------------

set -ex

#Disable SELINUX
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux