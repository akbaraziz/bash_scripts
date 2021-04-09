#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/tested/remove_files_after_x_days.sh
# Script create date: 07/02/2020
# Script ver: 1.0.0
# Script purpose: Remove files after X number of days
# Script tested on OS: CentOS 7.x
#--------------------------------------------------

set -ex

# Add Directory Path to command
find /path/to/files* -mtime +7 -exec rm {} ;