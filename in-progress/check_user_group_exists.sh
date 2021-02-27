#!/bin/sh
echo "Search user:"
read -r typed
if id "$typed" > /dev/null 2>&1
then
    echo "user exist!"
else
    echo "user doesn't exist"
fi


#!/bin/bash
if id -u "$1" >/dev/null 2>&1; then
    echo "user exists"
else
    echo "user does not exist"
fi


id -u somename &>/dev/null || useradd somename


grep -E "^groupname" /etc/group;
if [ $? -eq 0 ]; then
    echo "Group Exists"
else
    echo "Group does not exist"
fi