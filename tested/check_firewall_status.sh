#!/bin/bash
# To check if the firewalld service is running on Centos and Redhat
# Created by: Akbar Aziz
# Date: 06/05/2020
# Version: 1.0


set -ex

if [ `systemctl is-active firewalld` ]
then
    firewall_status=active
else
    firewall_status=inactive
fi