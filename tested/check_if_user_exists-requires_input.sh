#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script create date: 07/02/2020
# Script ver: 1.0
# Script tested on OS: CentOS 7.x
# Script purpose: Check if User Exists on System

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