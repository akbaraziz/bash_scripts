#!/bin/bash

set -ex

# Install yum-cron
sudo yum install -y yum-cron

# Enable and Start Service
sudo systemctl enable yum-cron
sudo systemctl start yum-cron

# Configure yum-cron
sudo cat >/etc/yum/yum-cron-hourly.conf <<EOL
[commands]
update_cmd = default
update_messages = no
download_updates = yes
apply_updates = yes
random_sleep = 360
[emitters]
system_name = None
emit_via = stdio
output_width = 80
[email]
email_from = root
email_to = root
email_host = localhost
[groups]
group_list = None
group_package_types = mandatory, default
[base]
debuglevel = -2
mdpolicy = group:main
EOL
