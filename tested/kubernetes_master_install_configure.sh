ca-key.pem -config=ca-config.json -profile=client kube-proxy-csr.json | cfssljson -bare kube-proxy
        
        echo '{
      "CN": "admin",
      "hosts": [],
      "key": {
        "algo": "rsa",
        "size": 2048
      },
      "names": [
        {
          "C": "US",
          "L": "San Jose",
          "O": "system:masters",
          "OU": "Cluster",
          "ST": "California"
        }
      ]
        }' | tee admin-csr.json
        
        cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=client admin-csr.json | cfssljson -bare admin
        
        count=0
        for ip in $(echo ${MASTER_IPS} | tr "," "\n"); do
            kubectl config set-cluster ${KUBE_CLUSTER_NAME} --certificate-authority=ca.pem --embed-certs=true --server=https://${INTERNAL_IP}:${MASTER_API_HTTPS} --kubeconfig=master${count}.kubeconfig
            kubectl config set-credentials system:node:master${count} --client-certificate=master${count}.pem --client-key=master${count}-key.pem --embed-certs=true --kubeconfig=master${count}.kubeconfig
            kubectl config set-context default --cluster=${KUBE_CLUSTER_NAME} --user=system:node:master${count} --kubeconfig=master${count}.kubeconfig
            kubectl config use-context default --kubeconfig=master${count}.kubeconfig
            count=$((count+1))
        done
        
        kubectl config set-cluster ${KUBE_CLUSTER_NAME} --certificate-authority=ca.pem --embed-certs=true --server=https://${INTERNAL_IP}:${MASTER_API_HTTPS} --kubeconfig=kube-controller-manager.kubeconfig
        kubectl config set-credentials kube-controller-manager --client-certificate=kube-controller-manager.pem --client-key=kube-controller-manager-key.pem --embed-certs=true --kubeconfig=kube-controller-manager.kubeconfig
        kubectl config set-context default --cluster=${KUBE_CLUSTER_NAME} --user=kube-controller-manager --kubeconfig=kube-controller-manager.kubeconfig
        kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig
        
        kubectl config set-cluster ${KUBE_CLUSTER_NAME} --certificate-authority=ca.pem --embed-certs=true --server=https://${INTERNAL_IP}:${MASTER_API_HTTPS} --kubeconfig=kube-scheduler.kubeconfig
        kubectl config set-credentials kube-scheduler --client-certificate=kube-scheduler.pem --client-key=kube-scheduler-key.pem --embed-certs=true --kubeconfig=kube-scheduler.kubeconfig
        kubectl config set-context default --cluster=${KUBE_CLUSTER_NAME} --user=kube-scheduler --kubeconfig=kube-scheduler.kubeconfig
        kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig
        
        kubectl config set-cluster ${KUBE_CLUSTER_NAME} --certificate-authority=ca.pem --embed-certs=true --server=https://${INTERNAL_IP}:${MASTER_API_HTTPS} --kubeconfig=kube-proxy.kubeconfig
        kubectl config set-credentials kube-proxy --client-certificate=kube-proxy.pem --client-key=kube-proxy-key.pem --embed-certs=true --kubeconfig=kube-proxy.kubeconfig
        kubectl config set-context default --cluster=${KUBE_CLUSTER_NAME} --user=kube-proxy --kubeconfig=kube-proxy.kubeconfig
        kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
        
        ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
        echo "kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
        - identity: {}" | tee encryption-config.yaml
        
        echo "@@{CENTOS.secret}@@" | tee ~/.ssh/id_rsa
        chmod 600 ~/.ssh/id_rsa
        
        count=0
        for ip in $(echo ${MASTER_IPS} | tr "," "\n"); do
            instance="master${count}"
            scp -o stricthostkeychecking=no admin*.pem ca*.pem kubernetes*.pem ${instance}* kube-proxy.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig encryption-config.yaml ${instance}:
            count=$((count+1))
        done
        
    else
        count=0
        while [ ! $(ls $HOME/encryption-config.yaml 2>/dev/null) ] ; do  echo "waiting for certs sleeping 5" && sleep 5; if [[ $count -eq 600 ]]; then echo "failed to download certs" && exit 1; fi; count=$(($count+5)) ; done
    fi
    
    cd $HOME
    sudo cp ca*.pem kubernetes*.pem ${NODE_NAME}* kube-*.kubeconfig encryption-config.yaml ${KUBE_CERT_PATH}/
    sudo chmod +r ${KUBE_CERT_PATH}/*
fi

sudo systemctl start kubelet
sudo systemctl enable kubelet
sudo systemctl restart rsyslog

mkdir CA
mv admin*.pem ca*.pem kubernetes*.pem master* kube-*.kubeconfig encryption-config.yaml CA/
if [ @@{calm_array_index}@@ -ne 0 ];then
    exit
fi

cp /opt/kube-ssl/admin*.pem CA/
COUNT=0
while [[ $(curl --key CA/admin-key.pem --cert CA/admin.pem --cacert CA/ca.pem https://${INTERNAL_IP}:${MASTER_API_HTTPS}/healthz) != "ok" ]] ; do
    echo "sleep for 5 secs"
    sleep 5
    COUNT=$(($COUNT+1))
    if [[ $COUNT -eq 50 ]]; then
        echo "Error: creating cluster"
        exit 1
    fi
done

kubectl config set-cluster ${KUBE_CLUSTER_NAME}  --certificate-authority=$HOME/CA/ca.pem  --embed-certs=true --server=https://${INTERNAL_IP}:${MASTER_API_HTTPS}
kubectl config set-credentials admin  --client-certificate=$HOME/CA/admin.pem  --client-key=$HOME/CA/admin-key.pem
kubectl config set-context ${KUBE_CLUSTER_NAME}  --cluster=${KUBE_CLUSTER_NAME}  --user=admin
kubectl config use-context ${KUBE_CLUSTER_NAME}

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:kube-apiserver-to-kubelet
rules:
  - apiGroups:
      - ""
    resources:
      - nodes/proxy
      - nodes/stats
      - nodes/log
      - nodes/spec
      - nodes/metrics
    verbs:
      - "*"
EOF

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: system:kube-apiserver
  namespace: ""
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kube-apiserver-to-kubelet
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: kubernetes
EOF