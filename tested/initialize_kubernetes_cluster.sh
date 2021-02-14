#!/bin/bash

set -ex

# Initialize Kubernetes Cluster Using Flananel
sudo kubeadm init --pod-network-cidr=10.244.0.0/16