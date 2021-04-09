#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/blob/master/tested/set_hostname_update_etc_hosts.sh
# Script date: 06/05/2020
# Script ver: 1.0.0
# Script purpose: To set host name
# Script tested on OS: CentOS and Redhat 7.x
#--------------------------------------------------

set -ex

HOST_NAME=@@{HOST_NAME}@@
IPADDR=@@{address}@@
sudo hostnamectl set-hostname ${HOST_NAME}

sudo echo ${HOST_NAME} | tee /etc/hostname
sudo sed -i -E 's/^127.0.1.1.*/127.0.1.1\t'"${HOST_NAME}"'/' /etc/hosts
sudo sed -i -E 's/^127.0.1.1.*/127.0.1.1\t'"${HOST_NAME}"'/' /etc/sysconfig/network
sudo echo -e ""${IPADDR}" "${HOST_NAME}"" >> /etc/hosts