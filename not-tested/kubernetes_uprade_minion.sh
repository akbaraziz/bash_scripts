#!/bin/bash

set -ex

KUBE_VERSION="@@{KUBE_VERSION_NEW}@@"
KUBELET_IMAGE_TAG="${KUBE_VERSION}_coreos.0"
INTERNAL_IP="@@{IP_ADDR}@@"
NODE_NAME="minion@@{calm_array_index}@@"
CLUSTER_SUBNET="@@{KUBE_CLUSTER_SUBNET}@@"
KUBE_CLUSTER_DNS="@@{KUBE_DNS_IP}@@"
DOCKER_VERSION="@@{DOCKER_VERSION}@@"
KUBE_CERT_PATH="/etc/kubernetes/ssl"
KUBE_MANIFEST_PATH="/etc/kubernetes/manifests"
VERSION=$(echo "${KUBELET_IMAGE_TAG}" | tr "_" " " | awk '{print $1}')

curl -C - -L -O --retry 6 --retry-max-time 60 --retry-delay 60 --silent --show-error https://storage.googleapis.com/kubernetes-release/release/${VERSION}/bin/linux/amd64/kubelet
chmod +x kubelet
sudo mv kubelet /usr/bin/kubelet

echo "[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=docker.service
Requires=docker.service

[Service]
ExecStart=/usr/bin/kubelet \\
  --allow-privileged=true \\
  --anonymous-auth=false \\
  --authentication-token-webhook \\
  --authorization-mode=Webhook \\
  --cluster-dns=${KUBE_CLUSTER_DNS} \\
  --cluster-domain=cluster.local \\
  --container-runtime=docker \\
  --enable-custom-metrics \\
  --kubeconfig=${KUBE_CERT_PATH}/${NODE_NAME}.kubeconfig \\
  --network-plugin=cni \\
  --pod-cidr=${CLUSTER_SUBNET} \\
  --register-node=true \\
  --runtime-request-timeout=10m \\
  --client-ca-file=${KUBE_CERT_PATH}/ca.pem \\
  --tls-cert-file=${KUBE_CERT_PATH}/${NODE_NAME}.pem \\
  --tls-private-key-file=${KUBE_CERT_PATH}/${NODE_NAME}-key.pem \\
  --pod-manifest-path=${KUBE_MANIFEST_PATH} \\
  --read-only-port=0 \\
  --protect-kernel-defaults=false \\
  --make-iptables-util-chains=true \\
  --keep-terminated-pod-volumes=false \\
  --event-qps=0 \\
  --cadvisor-port=0 \\
  --runtime-cgroups=/systemd/system.slice \\
  --kubelet-cgroups=/systemd/system.slice \\
  --eviction-hard=memory.available<100Mi,nodefs.available<10%,nodefs.inodesFree<5% \\
  --node-labels 'node-role.kubernetes.io/worker=true' \\
  --node-labels 'beta.kubernetes.io/fluentd-ds-ready=true' \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/kubelet.service

echo "apiVersion: v1
kind: Pod
metadata:
  name: kube-proxy
  namespace: kube-system
  labels:
    k8s-app: kube-proxy
spec:
  hostNetwork: true
  containers:
  - name: kube-proxy
    image: quay.io/coreos/hyperkube:${KUBELET_IMAGE_TAG}
    command:
    - /hyperkube
    - proxy
    - --cluster-cidr=${CLUSTER_SUBNET}
    - --masquerade-all=true
    - --kubeconfig=${KUBE_CERT_PATH}/kube-proxy.kubeconfig
    - --proxy-mode=iptables
    securityContext:
      privileged: true
    volumeMounts:
    - mountPath: ${KUBE_CERT_PATH}
      name: ssl-certs-kubernetes
      readOnly: true
    - mountPath: /etc/ssl/certs
      name: ssl-certs-host
      readOnly: true
  volumes:
  - hostPath:
      path: ${KUBE_CERT_PATH}
    name: ssl-certs-kubernetes
  - hostPath:
      path: /etc/ssl/certs
    name: ssl-certs-host" | sudo tee ${KUBE_MANIFEST_PATH}/kube-proxy.yaml