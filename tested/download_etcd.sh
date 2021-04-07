Download ETCD

curl -s https://api.github.com/repos/etcd-io/etcd/releases/latest \
  | grep browser_download_url \
  | grep linux-amd64 \
  | cut -d '"' -f 4 \
  | wget -qi -

count=1
for ip in $(echo "${ETCD_IPS}" | tr "," "\n"); do
    echo "${ip} clcpletcds${count}" | sudo tee -a /etc/hosts
    count=$((count+1))
done