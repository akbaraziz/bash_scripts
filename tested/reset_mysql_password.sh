#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script create date: 07/02/2020
# Script ver: 1.0
# Script tested on OS: CentOS 7.x
# Script purpose: Reset MySQL Password

#--------------------------------------------------

set -ex

# Fix to obtain temp password and set it to blank
password=$(sudo grep -oP 'temporary password(.*): \K(\S+)' /var/log/mysqld.log)
sudo mysqladmin --user=root --password="$password" password aaBB**cc1122
sudo mysql --user=root --password=aaBB**cc1122 -e "UNINSTALL COMPONENT 'file://component_validate_password'"
sudo mysqladmin --user=root --password="aaBB**cc1122" password ""