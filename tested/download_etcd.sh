#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/blob/master/tested/download_etcd.sh
# Script date: 06/05/2020
# Script ver: 1.0.0
# Script purpose: To download ETCD for Linux
# Script tested on OS: CentOS and Redhat 7.x
#--------------------------------------------------

set -ex

# Download ETCD
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