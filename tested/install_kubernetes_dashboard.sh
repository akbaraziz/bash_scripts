#!/bin/bash

set -ex

# Installation of Kubernetes Dashboard from Nutanix Dev Team

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml
sleep 10

echo "Creating SA for the dashboard"
kubectl create serviceaccount dashboard -n kubernetes-dashboard

echo "Creating Cluster Role Binding for the dashboard"
kubectl create clusterrolebinding admin-user  -n kubernetes-dashboard  --clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:admin-user

echo "Getting the token info for Dashboard"
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')
sleep 5

echo "Type kubeproxy command then you can connect the dashboard from local"
echo "kubectl proxy"
echo "open this url from your browser: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login"