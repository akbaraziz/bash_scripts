#!/bin/bash
# Script author: Akbar Aziz - modified from original script by Danie Pham
# Script site: https://www.writebash.com
# Script date: 11/30/2020
# Script ver: 1.0
# Script use to install Apache on CentOS 7.x
#--------------------------------------------------
# Software version:
# 1. OS: CentOS 7.9.2004 (Core) 64bit.
# 2. Apache: Apache 2.4.46 (CentOS)
#
#--------------------------------------------------

# Function check user root
f_check_root () {
    if (( $EUID == 0 )); then
        # If user is root, continue to function f_sub_main
        f_sub_main
    else
        # If user not is root, print message and exit script
        echo "Please run this script by user root !"
        exit
    fi
}

# Disable SELINUX
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

# Function install Apache
f_install_apache () {
    ########## INSTALL APACHE ##########
    echo "Installing apache ..."
    sleep 1

    yum install httpd -y

    # This part is optimize for server 2GB RAM
    cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.original
    sed -i '/<IfModule prefork.c/,/<\/IfModule/{//!d}' /etc/httpd/conf/httpd.conf
    sed -i '/<IfModule prefork.c/a\ StartServers              4\n MinSpareServers           20\n MaxSpareServers           40\n MaxClients         200\n MaxRequestsPerChild    4500' /etc/httpd/conf/httpd.conf

    # Enable and start httpd service
    systemctl enable httpd.service
    systemctl restart httpd.service
}

# Function enable port 80,433 in IPtables
f_open_port () {
    firewall-cmd --permanent --add-service=http
    firewall-cmd --permanent --add-service=https
    firewall-cmd --permanent --add-port=80/tcp
    firewall-cmd --permanent --add-port=443/tcp
    firewall-cmd --reload
}

# The sub main function, use to call neccessary functions of installation
f_sub_main () {
    f_install_apache
    f_open_port
    sleep 1
}

# The main function
f_main () {
    f_check_root
}
f_main

exit