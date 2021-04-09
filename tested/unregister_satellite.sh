#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/tested/unregister_satellite.sh
# Script create date: 07/02/2020
# Script ver: 1.0.0
# Script purpose: Unregister system from Satellite Server
# Script tested on OS: Redhat 7.x
#--------------------------------------------------

set -ex

# Unregister from Satellite or RHN
sudo subscription-manager remove --all
sudo subscription-manager unregister
sudo subscription-manager clean