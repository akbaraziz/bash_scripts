#!/bin/bash

# Shell script input parsing here

system-config-network-cmd -i <<EOF
DeviceList.Ethernet.eth0.type=Ethernet
DeviceList.Ethernet.eth0.BootProto=static
DeviceList.Ethernet.eth0.OnBoot=True
DeviceList.Ethernet.eth0.NMControlled=False
DeviceList.Ethernet.eth0.Netmask=255.255.255.128
DeviceList.Ethernet.eth0.IP=@@{IP_ADDRESS_MASTER}@@
DeviceList.Ethernet.eth0.Gateway=@@{GATEWAY}@@
ProfileList.default.ActiveDevices.1=eth0
EOF

service network stop
service network start