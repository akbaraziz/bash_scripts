#!/bin/bash

set -ex

# Disable SWAP volume
swapoff -a
sed -i '/ swap/ s/^/#/' /etc/fstab