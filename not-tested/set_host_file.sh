#!/bin/bash

set -ex

MINION_IPS="@@{AHV_RHEL_K8SM.address}@@"
for ip in $(echo ${MINION_IPS} | tr "," "\n"); do
  if ! (( $(grep -c "${ip} minion${count}" /etc/hosts) )) ; then
  	echo "${ip} minion${count}" | sudo tee -a /etc/hosts
  fi
  count=$((count+1))
done