#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script date: 06/19/2020
# Script ver: 1.0
# Script tested on OS: CentOS 7.x
# Script purpose: Check if a Service is running and prompt to start if needed

#--------------------------------------------------

set -ex

if [ "$#" = 0 ]

then
echo "Usage $0 "

exit 1

fi

service=$1

is_running=`ps aux | grep -v grep| grep -v "$0" | grep $service| wc -l | awk '{print $1}'`

if [ $is_running != "0" ] ;

then

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
