#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/blob/master/tested/check_cpu_requirements.sh
# Script date: 04/05/2021
# Script ver: 1.0.0
# Script purpose: To check if minimum CPU's are on the Server
# Script tested on OS: CentOS and Redhat 7.x
#--------------------------------------------------

set -ex

# Check if minimum CPUs exist on Server

CPU_COUNT=$(nproc)
echo $CPU_COUNT  >/dev/null 2>&1

if [ $CPU_COUNT -lt 2 ]
then
    
    echo "Sorry Your Server does not meet the required minimum number of CPUs (2), Script now will exit"
    exit
    
else
    echo "Required minium CPUs (2) are Validated.."
fi