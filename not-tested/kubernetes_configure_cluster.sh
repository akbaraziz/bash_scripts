#!/bin/bash

set -ex

K8_MASTER=192.168.163.133
K8_SUBNET=192.168.163.0/24

# Initializing Master
kubeadm init --apiserver-advertise-address=$K8_MASTER --pod-network-cidr=$K8_SUBNET
