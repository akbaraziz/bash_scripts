#!/bin/bash

set -ex

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