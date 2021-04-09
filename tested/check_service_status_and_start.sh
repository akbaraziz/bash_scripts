#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/blob/master/tested/check_if_user_exists-requires_input.sh
# Script date: 06/05/2020
# Script ver: 1.0.0
# Script purpose: To check service status and start if not running
# Script tested on OS: CentOS and Redhat 7.x
#--------------------------------------------------

set -ex

if [ "$#" = 0 ]
then
    echo "Usage $0 "
exit 1
fi

service=$1
is_running=`ps aux | grep -v grep| grep -v "$0" | grep $service| wc -l | awk '{print $1}'`
if [ $is_running != "0" ] ; then
echo "Service $service is running"
else
echo
initd=`ls /etc/init.d/ | grep $service | wc -l | awk '{ print $1 }'`

if [ $initd = "1" ];

then
startup=`ls /etc/init.d/ | grep $service`

echo -n "Found startap script /etc/init.d/${startup}. Start it? Y/n ? "

read answer

if [ $answer = "y" -o $answer = "Y" ];

then
echo "Starting service..."

/etc/init.d/${startup} start

fi

fi
