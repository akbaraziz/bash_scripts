#!/bin/bash

set -ex

    service="service name"

    if (( $(ps -ef | grep -v grep | grep $service | wc -l) > 0 ))
    then
      echo "$service is running!!!"
    else
      /usr/lib/systemd/system/$service start
    fi