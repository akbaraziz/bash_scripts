#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/blob/master/tested/set_hostname.sh
# Script date: 06/05/2020
# Script ver: 1.0.0
# Script purpose: To set host name
# Script tested on OS: CentOS and Redhat 7.x
#--------------------------------------------------

set -ex

OLD_HOSTNAME="$( hostname )"
NEW_HOSTNAME="$1"

if [ -z "$NEW_HOSTNAME" ]; then
    echo -n "Please enter new hostname: "
    read NEW_HOSTNAME < /dev/tty
fi

if [ -z "$NEW_HOSTNAME" ]; then
    echo "Error: no hostname entered. Exiting."
    exit 1
fi

echo "Changing hostname from $OLD_HOSTNAME to $NEW_HOSTNAME..."

hostnamectl set-hostname "$NEW_HOSTNAME"

sed -i "s/HOSTNAME=.*/HOSTNAME=$NEW_HOSTNAME/g" /etc/sysconfig/network

if [ -n "$( grep "$OLD_HOSTNAME" /etc/hosts )" ]; then
    sed -i "s/$OLD_HOSTNAME/$NEW_HOSTNAME/g" /etc/hosts
else
    echo -e "$( hostname -I | awk '{ print $1 }' )\t$NEW_HOSTNAME" >> /etc/hosts
fi

echo "Set system hostname to ${NEW_HOSTNAME}"