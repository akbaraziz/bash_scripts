#!/bin/bash
# To install Google Chrome on linux systems.
# Created by: Akbar Aziz
# Date: 06/05/2020
# Version: 1.0


set -ex

# Download Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm

# Install Dependencies and Chrome
yum -y install redhat-lsb libXScrnSaver
yum -y localinstall google-chrome-stable_current_x86_64.rpm