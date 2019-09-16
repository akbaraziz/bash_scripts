#!/bin/bash

set -ex

ETCD_VERSION="v3.3.12"
KUBE_VERSION="@@{KUBE_VERSION_NEW}@@"
KUBELET_IMAGE_TAG="${K8_VERSION}_coreos.0"
INTERNAL_IP="@@{IP_ADDR}@@"
CONTROLLER_IPS="@@{calm_array_address}@@"
NODE_NAME="controller@@{calm_array_index}@@"
CLUSTER_SUBNET="@@{KUBE_CLUSTER_SUBNET}@@"
SERVICE_SUBNET="@@{KUBE_SERVICE_SUBNET}@@"
KUBE_CLUSTER_DNS="@@{KUBE_DNS_IP}@@"
DOCKER_VERSION="@@{DOCKER_VERSION}@@"
ETCD_CERT_PATH="/etc/ssl/certs/etcd"
KUBE_CERT_PATH="/etc/kubernetes/ssl"
KUBE_MANIFEST_PATH="/etc/kubernetes/manifests"
VERSION=$(echo "${KUBELET_IMAGE_TAG}" | tr "_" " " | awk '{print $1}')
MASTER_API_HTTPS=6443
ETCD_SERVER_PORT=2379
CONTROLLER_COUNT=$(echo "@@{calm_array_address}@@" | tr ',' '\n' | wc -l)


count=0
for ip in $(echo "${CONTROLLER_IPS}" | tr "," "\n"); do
  ETCD+="https://${ip}:${ETCD_SERVER_PORT}",
  count=$((count+1))
done
ETCD_SERVERS=$(echo $ETCD | sed  's/,$//')

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
  --node-labels 'node-role.kubernetes.io/master=true' \\
  --node-labels 'node-role.kubernetes.io/etcd=true' \\
  --register-with-taints=node-role.kubernetes.io/master=true:NoSchedule \\
  --node-labels 'beta.kubernetes.io/fluentd-ds-ready=true' \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/kubelet.service

echo "apiVersion: v1
kind: Pod
metadata:
  name: kube-apiserver
  namespace: kube-system
  labels:
    k8s-app: kube-apiserver
spec:
  hostNetwork: true
  containers:
  - name: kube-apiserver
    image: quay.io/coreos/hyperkube:${KUBELET_IMAGE_TAG}
    command:
    - /hyperkube
    - apiserver
    - --admission-control=Initializers,NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota,AlwaysPullImages,DenyEscalatingExec,SecurityContextDeny,EventRateLimit
    - --advertise-address=${INTERNAL_IP}
    - --allow-privileged=true
    - --anonymous-auth=false
    - --insecure-port=0
    - --secure-port=${MASTER_API_HTTPS}
    - --profiling=false
    - --repair-malformed-updates=false
    - --apiserver-count=${CONTROLLER_COUNT}
    - --audit-log-maxage=30
    - --audit-log-maxbackup=10
    - --audit-log-maxsize=100
    - --audit-log-path=/var/lib/audit.log
    - --authorization-mode=Node,RBAC
    - --bind-address=0.0.0.0
    - --kubelet-preferred-address-types=InternalIP,Hostname,ExternalIP
    - --event-ttl=1h
    - --service-account-lookup=true
    - --enable-swagger-ui=true
    - --storage-backend=etcd3
    - --etcd-cafile=${ETCD_CERT_PATH}/etcd-ca.pem
    - --etcd-certfile=${ETCD_CERT_PATH}/etcd-client.pem
    - --etcd-keyfile=${ETCD_CERT_PATH}/etcd-client-key.pem
    - --etcd-servers=${ETCD_SERVERS}
    - --experimental-encryption-provider-config=${KUBE_CERT_PATH}/encryption-config.yaml
    - --admission-control-config-file=${KUBE_CERT_PATH}/admission-control-config-file.yaml
    - --tls-ca-file=${KUBE_CERT_PATH}/ca.pem
    - --tls-cert-file=${KUBE_CERT_PATH}/kubernetes.pem
    - --tls-private-key-file=${KUBE_CERT_PATH}/kubernetes-key.pem
    - --kubelet-certificate-authority=${KUBE_CERT_PATH}/ca.pem
    - --kubelet-client-certificate=${KUBE_CERT_PATH}/kubernetes.pem
    - --kubelet-client-key=${KUBE_CERT_PATH}/kubernetes-key.pem
    - --kubelet-https=true
    - --runtime-config=api/all
    - --service-account-key-file=${KUBE_CERT_PATH}/kubernetes.pem
    - --service-cluster-ip-range=${SERVICE_SUBNET}
    - --service-node-port-range=30000-32767
    - --client-ca-file=${KUBE_CERT_PATH}/ca.pem
    - --v=2
    ports:
    - containerPort: ${MASTER_API_HTTPS}
      hostPort: ${MASTER_API_HTTPS}
      name: https
    - containerPort: 8080
      hostPort: 8080
      name: local
    volumeMounts:
    - mountPath: ${KUBE_CERT_PATH}
      name: ssl-certs-kubernetes
      readOnly: true
    - mountPath: /etc/ssl/certs
      name: ssl-certs-host
      readOnly: true
    - mountPath: /etc/pki
      name: ca-certs-etc-pki
      readOnly: true
  volumes:
  - hostPath:
      path: ${KUBE_CERT_PATH}
    name: ssl-certs-kubernetes
  - hostPath:
      path: /etc/ssl/certs
    name: ssl-certs-host
  - hostPath:
      path: /etc/pki
    name: ca-certs-etc-pki" | sudo tee ${KUBE_MANIFEST_PATH}/kube-apiserver.yaml

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
    
echo "apiVersion: v1
kind: Pod
metadata:
  name: kube-controller-manager
  namespace: kube-system
  labels:
    k8s-app: kube-controller-manager
spec:
  hostNetwork: true
  containers:
  - name: kube-controller-manager
    image: quay.io/coreos/hyperkube:${KUBELET_IMAGE_TAG}
    command:
    - /hyperkube
    - controller-manager
    - --address=0.0.0.0  
    - --allocate-node-cidrs=true  
    - --cluster-cidr=${CLUSTER_SUBNET}
    - --cluster-name=kubernetes-prod-cluster  
    - --leader-elect=true  
    - --kubeconfig=${KUBE_CERT_PATH}/kube-controller-manager.kubeconfig  
    - --service-account-private-key-file=${KUBE_CERT_PATH}/kubernetes-key.pem
    - --root-ca-file=${KUBE_CERT_PATH}/ca.pem
    - --service-cluster-ip-range=${SERVICE_SUBNET}
    - --terminated-pod-gc-threshold=100  
    - --profiling=false  
    - --use-service-account-credentials=true
    - --horizontal-pod-autoscaler-use-rest-clients=false 
    - --v=2
    livenessProbe:
      httpGet:
        host: 127.0.0.1
        path: /healthz
        port: 10252
      initialDelaySeconds: 15
      timeoutSeconds: 1
    volumeMounts:
    - mountPath: ${KUBE_CERT_PATH}
      name: ssl-certs-kubernetes
      readOnly: true
    - mountPath: /etc/ssl/certs
      name: ssl-certs-host
      readOnly: true
    - mountPath: /etc/pki
      name: ca-certs-etc-pki
      readOnly: true
  volumes:
  - hostPath:
      path: ${KUBE_CERT_PATH}
    name: ssl-certs-kubernetes
  - hostPath:
      path: /etc/ssl/certs
    name: ssl-certs-host
  - hostPath:
      path: /etc/pki
    name: ca-certs-etc-pki" | sudo tee ${KUBE_MANIFEST_PATH}/kube-controller-manager.yaml
    
echo "apiVersion: v1
kind: Pod
metadata:
  name: kube-scheduler
  namespace: kube-system
  labels:
    k8s-app: kube-scheduler
spec:
  hostNetwork: true
  containers:
  - name: kube-scheduler
    image: quay.io/coreos/hyperkube:${KUBELET_IMAGE_TAG}
    command:
    - /hyperkube
    - scheduler
    - --kubeconfig=${KUBE_CERT_PATH}/kube-scheduler.kubeconfig
    - --leader-elect=true
    - --profiling=false
    - --v=2
    livenessProbe:
      httpGet:
        host: 127.0.0.1
        path: /healthz
        port: 10251
      initialDelaySeconds: 15
      timeoutSeconds: 1
    volumeMounts:
    - mountPath: ${KUBE_CERT_PATH}
      name: ssl-certs-kubernetes
      readOnly: true
  volumes:
  - hostPath:
      path: ${KUBE_CERT_PATH}
    name: ssl-certs-kubernetes" | sudo tee ${KUBE_MANIFEST_PATH}/kube-scheduler.yaml