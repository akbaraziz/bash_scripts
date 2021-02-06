#!/bin/bash

set -ex

# Install required RPM's
sudo yum -y install libguestfs libguestfs-tools
sudo virt-customize -a CentOS-8-GenericCloud-8.3.2011-20201204.2.x86_64.qcow2 --root-password password:'yourpassword'