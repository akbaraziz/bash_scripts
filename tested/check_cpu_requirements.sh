#!/bin/bash

set -ex

#Check if minimum CPUs there on Server.

CPU_COUNT=$(nproc)
echo $CPU_COUNT  >/dev/null 2>&1

if [ $CPU_COUNT -lt 2 ]
then
    
    echo "Sorry Your Server does not meet the required minimum number of CPUs (2), Script now will exit"
    exit
    
else
    echo "Required minium CPUs (2) are Validated.."
fi