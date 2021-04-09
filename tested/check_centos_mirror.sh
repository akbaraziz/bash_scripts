#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/blob/master/tested/check_centos_mirror.sh
# Script date: 03/21/2021
# Script ver: 1.0.0
# Script purpose: To check CentOS Mirror Availability
# Script tested on OS: CentOS 7.x
#--------------------------------------------------

set -ex

# Verify access to Centos mirror before yum update
count=0
check_mirror() {
    curl -s mirrorlist.centos.org >/dev/null | true
    if [ "${PIPESTATUS[0]}" -ne 0 ]; then
        if [ ${count} -lt 60 ]; then
            echo "Sleeping for 5 seconds before repeating the check" | sudo tee -a /var/log/messages
            sleep 5
            count=$((count+1))
            check_mirror
        else
            echo "DNS resolution failed after 5 minutes, exiting" | sudo tee -a /var/log/messages
            exit 1
        fi
    fi
}
check_mirror