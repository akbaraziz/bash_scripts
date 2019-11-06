#!/bin/bash

set -ex

# Download Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm

# Install Dependencies and Chrome
yum -y install redhat-lsb libXScrnSaver
yum -y localinstall google-chrome-stable_current_x86_64.rpm