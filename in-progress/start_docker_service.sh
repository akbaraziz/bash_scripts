#!/bin/bash

set -ex

# Enable Docker service at boot time
systemctl restart docker && systemctl enable docker

if [ $? == 0 ]; then
    echo "Docker service enabled on boot"
else
    echo "Docker service not enabled on boot"
fi