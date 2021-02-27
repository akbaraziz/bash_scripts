#!/bin/bash
wget https://storage.googleapis.com/kubernetes-helm/helm-v2.12.2-linux-amd64.tar.gz
tar -zxvf helm-v2.17.0-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/helm
kubectl -n kube-system create sa tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account tiller
kubectl create namespace kubeapps
helm install --name kubeapps --namespace kubeapps bitnami/kubeapps


