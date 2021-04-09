#!/bin/bash

set -ex

USER=name
CONTROL_PLANE_IPS="host1,host2"
for host in ${CONTROL_PLANE_IPS}; do
	mkdir /home/"${USER}"/certs
	scp -r /etc/kubernetes/pki/ca.crt "${USER}"@host:/home/"${USER}"/certs
	scp -r /etc/kubernetes/pki/ca.key "${USER}"@host:/home/"${USER}"/certs
	scp -r /etc/kubernetes/pki/ca.key "${USER}"@host:/home/"${USER}"/certs
	scp -r /etc/kubernetes/pki/ca.crt "${USER}"@host:/home/"${USER}"/certs