#!/bin/bash

set -ex

# Copy id_rsa.pub to multiple servers defined in a file
for ip in `cat /home/list_of_servers`; do
    ssh-copy-id -i ~/.ssh/id_rsa.pub $ip
done