#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/tested/install_yum-cron.sh
# Script date: 06/05/2020
# Script ver: 1.0.0
# Script tested on OS: CentOS 7.x
# Script purpose: Install yum-cron
#--------------------------------------------------

set -ex

# Install yum-cron
sudo yum install -y yum-cron --quiet

# Enable and Start Service
sudo systemctl enable --now yum-cron

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
