#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/blob/master/tested/check_if_user_exists-requires_input.sh
# Script date: 06/05/2020
# Script ver: 1.0.0
# Script purpose: To check if user exists on Server
# Script tested on OS: CentOS and Redhat 7.x
#--------------------------------------------------

set -ex

echo "Search user:"
read typed
if id $typed > /dev/null 2>&1
then
    echo "user exist!"
else
    echo "user doesn't exist"
fi