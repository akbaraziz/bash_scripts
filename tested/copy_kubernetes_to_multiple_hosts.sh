#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/tested/copy_kubernetes_to_multiple_hosts.sh
# Script create date: 07/02/2020
# Script ver: 1.0.0
# Script purpose: SCP Kubernetes Certificates to multiple hosts
# Script tested on OS: CentOS 7.x
#--------------------------------------------------

set -ex

USER=name
CONTROL_PLANE_IPS="host1,host2"
for host in ${CONTROL_PLANE_IPS}; do
    mkdir /home/"${USER}"/certs
    scp -r /etc/kubernetes/pki/ca.crt "${USER}"@host:/home/"${USER}"/certs
    scp -r /etc/kubernetes/pki/ca.key "${USER}"@host:/home/"${USER}"/certs
    scp -r /etc/kubernetes/pki/ca.key "${USER}"@host:/home/"${USER}"/certs
    scp -r /etc/kubernetes/pki/ca.crt "${USER}"@host:/home/"${USER}"/certs
done