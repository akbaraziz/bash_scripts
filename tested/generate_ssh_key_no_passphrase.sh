#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script date: 06/05/2020
# Script ver: 1.0
# Script tested on OS: CentOS 7.x
# Script purpose: Generate SSH Keys with no passphrase

#--------------------------------------------------

set -ex

# Generate SSH Key with no passphrase
ssh-keygen -t rsa -N ''

# Generate SSH Key with no passphrase replacing existing id_rsa key
ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa 2>/dev/null <<< y >/dev/null