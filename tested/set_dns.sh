#!/bin/bash

set -ex

IP1=10.10.10.5
IP2=10.10.10.7
IP3=192.168.1.1

sudo nmcli con mod eth0 ipv4.dns "$IP1,$IP2,$IP3"
sudo nmcli connection reload