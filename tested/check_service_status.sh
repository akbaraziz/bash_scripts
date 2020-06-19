#!/bin/bash

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
