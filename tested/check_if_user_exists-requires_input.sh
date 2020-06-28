#!/bin/bash
# To check is a user exists on systems running Centos and Redhat. Requires user input.
# Created by: Akbar Aziz
# Date: 06/05/2020
# Version: 1.0


set -ex

echo "Search user:"
read typed
if id $typed > /dev/null 2>&1
then
   echo "user exist!"
else
  echo "user doesn't exist"
fi