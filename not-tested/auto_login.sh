#!/bin/bash
# Script by: Danie Pham 
# Website: https://www.writebash.com 
# Script date: 26-12-2017 
# Script ver: 1.0

set -ex

yum install expect tcl -y

echo;
echo "Select the server to ssh"
echo "---------------------"
echo "1) server-01"
echo "2) server-02"
echo "---------------------"
read NUM
case $NUM in
1)
cd /home/scripts
./server-01
;;
2)
cd /home/scripts
./server-02
;;
*)
echo "Select again"
esac