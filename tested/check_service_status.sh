#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/blob/master/tested/check_service_status.sh
# Script create date: 07/02/2020
# Script ver: 1.0.0
# Script tested on OS: CentOS 7.x
# Script purpose: Check Service Status
#--------------------------------------------------

set -ex

# Which service to check
service=

# Check Service Status
host=`hostname -f`
if (( $(ps -ef | grep -v grep | grep $service | wc -l) > 0 ))
then
echo "$service is running"
else
/usr/sbin/service $service start
if (( $(ps -ef | grep -v grep | grep $service | wc -l) > 0 ))
then
echo "$service on $host has been started"
fi
