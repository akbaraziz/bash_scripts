#!/bin/bash

set -ex

HELM_VER=v2.16.7
HELM_URL=https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VER}-linux-amd64.tar.gz

wget ${HELM_URL}/helm-${HELM_VER}-linux-amd64.tar.gz
sudo tar -zxvf helm-${HELM_VER}-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm

sudo kubectl -n kube-system create sa tiller
sudo kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller

sudo helm init --service-account tiller
sudo kubectl create namespace kubeapps
#sudo helm install --name kubeapps --namespace kubeapps bitnami/kubeapps

