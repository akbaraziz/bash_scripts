#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script create date: 07/02/2020
# Script ver: 1.0
# Script tested on OS: CentOS 7.x
# Script purpose: Install Helm Charts for Kubernetes

#--------------------------------------------------

set -ex

HELM_VER=v2.16.7
HELM_URL=https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VER}-linux-amd64.tar.gz

wget ${HELM_URL}/helm-${HELM_VER}-linux-amd64.tar.gz
sudo tar -zxvf helm-${HELM_VER}-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm

sudo kubectl -n kube-system create sa tiller
sudo kubectl create clusterrolebinding tiller --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

sudo helm init --service-account tiller
sudo kubectl create namespace kubeapps

sudo helm repo add stable https://kubernetes-charts.storage.googleapis.com/

# Install a Helm Chart
sudo helm install stable/kubernetes-dashboard

# Check if Helm Service is running
sudo kubectl get services