#!/bin/bash
set -ex

KUBE_VERSION="@@{K8_VERSION}@@"
KUBELET_IMAGE_TAG="${KUBE_VERSION}_coreos.0"
INTERNAL_IP="@@{IP_ADDR}@@"
CONTROLLER_IPS="@@{AHV_RHEL_K8SC.address}@@"
NODE_NAME="minion@@{calm_array_index}@@"
CLUSTER_SUBNET="@@{KUBE_CLUSTER_SUBNET}@@"
SERVICE_SUBNET="@@{KUBE_SERVICE_SUBNET}@@"
KUBE_CLUSTER_DNS="@@{KUBE_DNS_IP}@@"
DOCKER_VERSION="@@{DOCKER_VERSION}@@"
KUBE_CERT_PATH="/etc/kubernetes/ssl"
KUBE_MANIFEST_PATH="/etc/kubernetes/manifests"
KUBE_CNI_BIN_PATH="/opt/cni/bin"
KUBE_CNI_CONF_PATH="/etc/cni/net.d"
ETCD_SERVER_PORT=2379

sudo mkdir -p ${KUBE_CERT_PATH} ${KUBE_MANIFEST_PATH} ${KUBE_CNI_CONF_PATH} ${KUBE_CNI_BIN_PATH}
sudo hostnamectl set-hostname --static ${NODE_NAME}

sudo yum update -y --quiet
sudo yum install -y iscsi-initiator-utils socat --quiet

curl -C - -L -O --retry 6 --retry-max-time 60 --retry-delay 60 --silent --show-error https://github.com/containernetworking/plugins/releases/download/v0.6.0/cni-plugins-amd64-v0.6.0.tgz
curl -C - -L -O --retry 6 --retry-max-time 60 --retry-delay 60 --silent --show-error https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubelet
curl -C - -L -O --retry 6 --retry-max-time 60 --retry-delay 60 --silent --show-error https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl
curl -C - -L -O --retry 6 --retry-max-time 60 --retry-delay 60 --silent --show-error https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 
curl -C - -L -O --retry 6 --retry-max-time 60 --retry-delay 60 --silent --show-error https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
chmod +x kubelet kubectl cfssl_linux-amd64 cfssljson_linux-amd64
sudo mv kubelet kubectl /usr/bin/
sudo mv cfssl_linux-amd64 /usr/local/bin/cfssl
sudo mv cfssljson_linux-amd64 /usr/local/bin/cfssljson

sudo yum install -y --quiet yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y --quiet --setopt=obsoletes=0 docker-ce-${DOCKER_VERSION} docker-ce-selinux-${DOCKER_VERSION}

sudo sed -i '/ExecStart=/c\\ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock' /usr/lib/systemd/system/docker.service
sudo systemctl enable docker
sudo usermod -a -G docker $USER

sudo mkdir -p /etc/docker
echo '{
  "storage-driver": "overlay"
}' | sudo tee /etc/docker/daemon.json

echo '{
  "name": "cbr0",
  "type": "flannel",
  "delegate": {
    "isDefaultGateway": true
  }
}' | sudo tee ${KUBE_CNI_CONF_PATH}/10-flannel.conf

sudo tar -zxvf cni-plugins-amd64-v0.6.0.tgz -C ${KUBE_CNI_BIN_PATH}
rm -rf cni-plugins-amd64-v0.6.0.tgz

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
      path: /usr/share/ca-certificates
    name: ssl-certs-host" | sudo tee ${KUBE_MANIFEST_PATH}/kube-proxy.yaml

echo "InitiatorName=iqn.1994-05.com.nutanix:k8s-worker" | sudo tee /etc/iscsi/initiatorname.iscsi

sudo mkdir -p /var/lib/docker
sudo yum install -y lvm2 --quiet
sudo pvcreate /dev/sd{b,c,d}
sudo vgcreate docker /dev/sd{b,c,d}
sleep 3
sudo lvcreate -l 100%VG -n docker_lvm docker
sudo mkfs.xfs /dev/docker/docker_lvm

echo -e "/dev/docker/docker_lvm \t /var/lib/docker \t xfs \t defaults \t 0 0" | sudo tee -a /etc/fstab
sudo mount -a

echo 'exclude=docker*' | sudo tee -a /etc/yum.conf

echo "@@{CENTOS.secret}@@" | tee ~/.ssh/id_rsa
chmod 400 ~/.ssh/id_rsa