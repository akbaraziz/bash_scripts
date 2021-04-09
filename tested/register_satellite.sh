#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/blob/master/tested/register_satellite.sh
# Script create date: 07/22/2020
# Script ver: 1.0.0
# Script tested on OS: Redhat 7.x and 8.x
# Script purpose: Register System with Redhat Satellite Server

#--------------------------------------------------

set -ex

USER=
PASSWORD=
ORGANIZATION=
ENVIRONMENT=

# Register to Satellite or RHN
subscription-manager register --username=${USER} --password=${PASSWORD} --org=${ORGANIZATION} --environment=${ENVIRONMENT} --auto-attach
echo

# Check license used by host
subscription-manager list --consumed