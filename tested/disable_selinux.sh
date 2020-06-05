#!/bin/bash
# To disable SELINUX on linux systems.
# Created by: Akbar Aziz
# Date: 06/05/2020
# Version: 1.0


set -ex

#Disable SELINUX
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux