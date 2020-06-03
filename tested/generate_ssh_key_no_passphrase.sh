#!/bin/bash

set -ex

# Generate SSH Key with no passphrase
ssh-keygen -t rsa -N ''


# Generate SSH Key with no passphrase replacing existing id_rsa key
ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa 2>/dev/null <<< y >/dev/null