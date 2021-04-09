#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/blob/master/tested/set_or_change_user_expiration.sh
# Script date: 06/05/2020
# Script ver: 1.0.0
# Script purpose: To set expiration date for user account
# Script tested on OS: CentOS and Redhat 7.x
#--------------------------------------------------

set -ex

USER=

# Check Password Age for User
chage -l $USER

# Set Account Expiration Date
chage -E "YYYY-MM-DD" $USER

# Disable Password Aging for User
chage -m 0 -M 9999 -I -1 -E -1 $USER