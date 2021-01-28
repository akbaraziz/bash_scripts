#!/bin/bash

set -ex

echo "Install epel-release..."
sudo yum install -y epel-release
echo "Install JQ..."
sudo yum install -y jq

#sudo setenforce 0
#sudo sed -i 's/permissive/disabled/' /etc/sysconfig/selinux

port=80

sudo yum install -y haproxy

sudo setsebool -P haproxy_connect_any on

echo "Get Node Pool..."
NODE_POOL=`curl -k -u "@@{PcAdmin.username}@@:@@{PcAdmin.secret}@@" \
-X GET -H "Accept: application/json" -H "Content-Type: application/json" \
https://@@{pc_ip}@@:9440/karbon/v1/k8s/clusters/@@{k8s_cluster_name}@@ \
| jq -r '.worker_config.node_pools | .[] '`

echo "Create Config File..."
echo "global
    log         127.0.0.1 local2
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon
    stats socket /var/lib/haproxy/stats
defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000
listen stats
    bind :9000
    mode http
    stats enable
    stats uri /
    monitor-uri /healthz
frontend ingress-http
    bind *:80
    default_backend ingress-http
    mode tcp
    option tcplog
backend ingress-http
    balance roundrobin
    mode tcp
option tcp-check" | sudo tee /etc/haproxy/haproxy.cfg

curl -k -u "@@{PcAdmin.username}@@:@@{PcAdmin.secret}@@" \
-X GET -H "Accept: application/json" -H "Content-Type: application/json" \
https://@@{pc_ip}@@:9440/karbon/v1-beta.1/k8s/clusters/@@{k8s_cluster_name}@@/node-pools/${NODE_POOL} \
| jq -r '.nodes | .[] | "    server \(.hostname) \(.ipv4_address):30080 check"' | sudo tee -a /etc/haproxy/haproxy.cfg


echo "
    frontend ingress-https
    bind *:443
    default_backend ingress-https
    mode tcp
    option tcplog
backend ingress-https
    balance roundrobin
    mode tcp
option tcp-check" | sudo tee -a /etc/haproxy/haproxy.cfg

curl -k -u "@@{PcAdmin.username}@@:@@{PcAdmin.secret}@@" \
-X GET -H "Accept: application/json" -H "Content-Type: application/json" \
https://@@{pc_ip}@@:9440/karbon/v1-beta.1/k8s/clusters/@@{k8s_cluster_name}@@/node-pools/${NODE_POOL} \
| jq -r '.nodes | .[] | "    server \(.hostname) \(.ipv4_address):30443 check"' | sudo tee -a /etc/haproxy/haproxy.cfg

sudo cat /etc/haproxy/haproxy.cfg

sudo sed -i 's/server host-/#server host-/g' /etc/haproxy/haproxy.cfg

sudo systemctl daemon-reload
sudo systemctl enable haproxy
sudo systemctl restart haproxy
