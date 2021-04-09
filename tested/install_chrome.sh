#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/blob/master/tested/install_chrome.sh
# Script date: 06/05/2020
# Script ver: 1.0.0
# Script purpose: Install Chrome on Linux
# Script tested on OS: CentOS 7.x
#--------------------------------------------------

set -ex

# Download Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm

# Install Dependencies and Chrome
yum -y install redhat-lsb libXScrnSaver --quiet
yum -y localinstall google-chrome-stable_current_x86_64.rpm --quiet