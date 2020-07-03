#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script create date: 07/02/2020
# Script ver: 1.0
# Script tested on OS: Redhat 7.x
# Script purpose: Unregister system from Satellite Server

#--------------------------------------------------

set -ex

# Unregister from Satellite or RHN
sudo subscription-manager unregister 