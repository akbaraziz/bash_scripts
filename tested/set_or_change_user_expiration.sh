#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script create date: 07/02/2020
# Script ver: 1.0
# Script tested on OS: CentOS 7.x
# Script purpose: Change User Account Expiration Date

#--------------------------------------------------

set -ex

USER=

# Check Password Age for User
chage -l $USER

# Set Account Expiration Date
chage -E "YYYY-MM-DD" $USER 

# Disable Password Aging for User
chage -m 0 -M 9999 -I -1 -E -1 $USER