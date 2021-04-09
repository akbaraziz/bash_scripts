#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/blob/master/tested/clear_linux_info.sh
# Script date: 06/05/2020
# Script ver: 1.0.0
# Script purpose: To clear Linux info before imaging
# Script tested on OS: CentOS and Redhat 7.x
#--------------------------------------------------

set -ex

# Clear Linux Info
/bin/find /var/log/ -type f -exec /bin/sh -c '>{}' \;