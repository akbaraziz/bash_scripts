#!/bin/bash

set -ex

    service="service name"

    if (( $(ps -ef | grep -v grep | grep $service | wc -l) > 0 ))
    then
      echo "$service is running!!!"
    else
      /usr/lib/systemd/system/$service start
    fi




#!/bin/sh
SERVICE=service;

if ps ax | grep -v grep | grep $SERVICE > /dev/null
then
    echo "$SERVICE service running, everything is fine"
else
    echo "$SERVICE is not running"
    echo "$SERVICE is not running!" | mail -s "$SERVICE down" root
fi





