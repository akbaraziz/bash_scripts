#!/bin/sh

set -ex

echo "Search user:"
read typed
if id $typed > /dev/null 2>&1
then
   echo "user exist!"
else
  echo "user doesn't exist"
fi