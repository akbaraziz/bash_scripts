#!/bin/bash

set -ex

if [ `systemctl is-active firewalld` ]
then
    firewall_status=active
else
    firewall_status=inactive
fi