#!/bin/bash

set -ex

if [ @@{calm_array_index}@@ -ne 0 ];then
  exit
fi

PRISM_CLUSTER_IP="@@{PE_CLUSTER_IP}@@"
PRISM_DATA_SERVICE_IP="@@{PE_CLUSTER_IP}@@"

if [[ ("${PRISM_CLUSTER_IP}x" == "x") && ("${PRISM_DATA_SERVICE_IP}x" == "x") ]]; then exit 0; fi
export PATH=$PATH:/opt/bin

sudo mkdir /etc/kubernetes/addons/volume_plugin
NTNX_SECRET=$(echo -n "@@{PE_USERNAME}@@:@@{PE_PASSWORD}@@" | base64)
echo 'apiVersion: v1
kind: ServiceAccount
metadata:
  name: nutanixabs-provisioner
  namespace: kube-system
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: nutanixabs-provisioner-runner
  namespace: kube-system
rules:
  - apiGroups: [""]
    resources: ["persistentvolumes"]
    verbs: ["get", "list", "watch", "create", "delete"]
  - apiGroups: [""]
    resources: ["persistentvolumeclaims"]
    verbs: ["get", "list", "watch", "update"]
  - apiGroups: ["storage.k8s.io"]
    resources: ["storageclasses"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["events"]
    verbs: ["list", "watch", "create", "update", "patch"]
  - apiGroups: [""]
    resources: ["services"]
    verbs: ["get"]
  - apiGroups: [""]
    resources: ["secrets"]
    verbs: ["get", "create", "delete"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: run-nutanixabs-provisioner
  namespace: kube-system
subjects:
  - kind: ServiceAccount
    name: nutanixabs-provisioner
    namespace: kube-system
roleRef:
  kind: ClusterRole
  name: nutanixabs-provisioner-runner
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: nutanixabs-provisioner
  namespace: kube-system
spec:
  replicas: 1
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: nutanixabs-provisioner
    spec:
      serviceAccount: nutanixabs-provisioner
      hostNetwork: true
      containers:
        -
          image: "ntnx/nutanixabs-provisioner"
          name: nutanixabs-provisioner
          args: ["--v=4"]
          imagePullPolicy: IfNotPresent
---
apiVersion: v1
kind: Secret
metadata:
  name: ntnx-secret
  namespace: kube-system
data:
  key: <SECRET>
type: nutanix/abs
---
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: silver 
  namespace: kube-system
  annotations:
    storageclass.beta.kubernetes.io/is-default-class: "true"
provisioner: nutanix/abs
parameters:
     prismEndPoint: @@{PE_CLUSTER_IP}@@:9440
     dataServiceEndPoint: @@{PE_DATA_SERVICE_IP}@@:3260
     secretName: ntnx-secret
     storageContainer: @@{PE_CONTAINER_NAME}@@
     fsType: ext4
     chapAuthEnabled: "false"' | sudo tee /etc/kubernetes/addons/volume_plugin/nutanix-provisioner.yaml

sudo sed -i "s/<SECRET>/${NTNX_SECRET}/" /etc/kubernetes/addons/volume_plugin/nutanix-provisioner.yaml
kubectl create -f /etc/kubernetes/addons/volume_plugin/nutanix-provisioner.yaml

echo "apiVersion: v1
kind: Secret
metadata:
  name: ntnx-secret
  namespace: default
data:
  key: <SECRET>
type: nutanix/abs" | sudo tee -a /etc/kubernetes/addons/volume_plugin/ntnx-secret.yaml
sudo sed -i "s/<SECRET>/${NTNX_SECRET}/" /etc/kubernetes/addons/volume_plugin/ntnx-secret.yaml
kubectl create -f /etc/kubernetes/addons/volume_plugin/ntnx-secret.yaml