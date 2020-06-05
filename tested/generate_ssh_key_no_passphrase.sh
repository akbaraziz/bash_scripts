#!/bin/bash
# To generate SSH keys with no passphrase and no user input on linux systems.
# Created by: Akbar Aziz
# Date: 06/05/2020
# Version: 1.0


set -ex

# Generate SSH Key with no passphrase
ssh-keygen -t rsa -N ''


# Generate SSH Key with no passphrase replacing existing id_rsa key
ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa 2>/dev/null <<< y >/dev/null