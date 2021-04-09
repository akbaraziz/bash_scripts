#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/blob/master/tested/get_system_info.sh
# Script create date: 07/02/2020
# Script ver: 1.0.0
# Script purpose: Get CPU and Memory Information
# Script tested on OS: CentOS 7.x
#--------------------------------------------------

set -ex

# Get System Information
function system_info {
    echo "### OS information ###"
    lsb_release -a
    
    echo
    echo "### Processor information ###"
    processor=`grep -wc "processor" /proc/cpuinfo`
    model=`grep -w "model name" /proc/cpuinfo  | awk -F: '{print $2}'`
    echo "Processor = $processor"
    echo "Model     = $model"
    
    echo
    echo "### Memory information ###"
    total=`grep -w "MemTotal" /proc/meminfo | awk '{print $2}'`
    free=`grep -w "MemFree" /proc/meminfo | awk '{print $2}'`
    echo "Total memory: $total kB"
    echo "Free memory : $free kB"
}