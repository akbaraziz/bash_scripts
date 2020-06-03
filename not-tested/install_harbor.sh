#!/bin/bash

set -ex

# Download Off-line Installer
wget https://storage.googleapis.com/harbor-releases/release-1.8.0/harbor-offline-installer-v1.8.2.tgz

# Extract Installer
sudo tar zxf harbor-offline-installer-v1.8.2.tgz


