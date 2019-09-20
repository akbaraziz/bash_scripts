#!/bin/bash

set -ex

# Install yum-cron
sudo yum install yum-cron -y

# Enable and Start Service
sudo systemctl enable yum-cron
sudo systemctl start yum-cron

# Modify yum-cron-hourly.conf
cat >/etc/yum/yum-cron-hourly.conf <<EOL
[commands]
update_cmd = security
update_messages = yes
download_updates = yes
apply_updates = yes
random_sleep = 360
[emitters]
system_name = None
emit_via = stdio
output_width = 80
[base]
debuglevel = -2
mdpolicy = group:main
EOL

