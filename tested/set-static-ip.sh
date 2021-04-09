#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/tested/set-static-ip.sh
# Script create date: 07/02/2020
# Script ver: 1.0.0
# Script purpose: Set Static IP Address on Server
# Script tested on OS: CentOS 7.x
#--------------------------------------------------

set -ex

NETMASK=
IP_ADDR=
GW=
DEVICE_ID=eth0

system-config-network-cmd -i <<EOF
DeviceList.Ethernet.eth0.type=Ethernet
DeviceList.Ethernet.eth0.BootProto=static
DeviceList.Ethernet.eth0.OnBoot=True
DeviceList.Ethernet.eth0.NMControlled=False
DeviceList.Ethernet.eth0.Netmask="${NETMASK}"
DeviceList.Ethernet.eth0.IP="${IP_ADDR}"
DeviceList.Ethernet.eth0.Gateway="${GW}"
ProfileList.default.ActiveDevices.1="${DEVICE_ID}"
EOF

service network stop
service network start