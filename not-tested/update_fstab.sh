#!/bin/bash

set -ex

# Add to /etc/fstab
echo -e "/dev/mapper/mysqlDataVG-mysqlDataLV /u	\t auto \t defaults \t 0 0" | sudo tee -a /etc/fstab
echo -e "/dev/mapper/mysqlLogVG-mysqlLogLV /mysqllogs \t auto \t defaults \t 0 0" | sudo tee -a /etc/fstab
echo -e "/dev/mapper/mysqlTempVG-mysqlTempLV /mysqltmp \t auto \t defaults \t 0 0" | sudo tee -a /etc/fstab
echo -e "/dev/mapper/mysqlBackupVG-mysqlBackupLV /mysqlbackup \t auto \t defaults \t 0 0" | sudo tee -a /etc/fstab