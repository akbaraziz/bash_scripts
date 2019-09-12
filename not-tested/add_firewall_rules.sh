#!/bin/bash

set -ex

for i in 80 443 22 
do
  firewall-cmd --zone=public --add-port=${i}/tcp
done

firewall-cmd --reload