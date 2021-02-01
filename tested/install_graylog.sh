#!/bin/bash

set -ex

## Initialize Variables
ADMIN_PASSWORD="@@{ADMIN_PASSWORD}@@"
ADMIN_EMAIL="@@{ADMIN_EMAIL}@@"
VM_IP="@@{STATIC_IP}@@"

HOST_NAME="@@{HOST_NAME}@@"
sudo hostnamectl set-hostname ${HOST_NAME}

sudo echo ${HOST_NAME} | tee /etc/hostname
sudo sed -i -E 's/^127.0.1.1.*/127.0.1.1\t'"${HOST_NAME}"'/' /etc/hosts
sudo sed -i -E 's/^127.0.1.1.*/127.0.1.1\t'"${HOST_NAME}"'/' /etc/sysconfig/network
sudo echo -e ""${VM_IP}" \t "${HOST_NAME}"" >> /etc/hosts


# Disable SELINUX
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

# Disable Firewall
sudo systemctl disable firewalld
sudo systemctl stop firewalld

## Install Java
sudo yum -y install epel-release
sudo yum install -y java-1.8.0-openjdk-headless.x86_64
sudo yum -y install pwgen

## Install mongo
echo '[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc' | sudo tee -a /etc/yum.repos.d/mongodb-org-4.2.repo
sudo yum makecache
sudo yum install -y mongodb-org
sudo systemctl enable --now mongod


## Install and configure elastic search
sudo rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
echo '[elasticsearch]
name=Elasticsearch repository
baseurl=https://artifacts.elastic.co/packages/oss-7.x/yum
gpgcheck=1
gpgkey=https://packages.elastic.co/GPG-KEY-elasticsearch
enabled=1' | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
sudo yum makecache
sudo yum -y install elasticsearch-oss

sudo tee -a /etc/elasticsearch/elasticsearch.yml > /dev/null <<EOT
cluster.name: graylog
action.auto_create_index: false
EOT

sudo systemctl daemon-reload
sudo systemctl enable --now elasticsearch

sleep 15

## Verify elastic search 
sudo curl -XGET 'http://localhost:9200/_cluster/health?pretty=true'


## Install graylog
sudo rpm -Uvh https://packages.graylog2.org/repo/packages/graylog-4.0-repository_latest.rpm
sudo yum update -y
sudo yum install -y graylog-server


## Configure graylog conf
sudo sed -i '/password_secret/s/^/#/' /etc/graylog/server/server.conf
sudo sed -i '/root_password_sha2/s/^/#/' /etc/graylog/server/server.conf
sudo sed -i '/elasticsearch_shards/s/^/#/' /etc/graylog/server/server.conf

pwd_secret=$(sudo pwgen -N 1 -s 96)
root_pwd=$(echo -n ${ADMIN_PASSWORD} | sha256sum | awk '{print $1}')


echo "password_secret=$pwd_secret
root_password_sha2=$root_pwd
root_email=${ADMIN_EMAIL}
root_timezone=UTC
elasticsearch_discovery_zen_ping_unicast_hosts = ${VM_IP}:9300
elasticsearch_shards=1
script.inline: false
script.indexed: false
http_bind_address = ${VM_IP}
script.file: false" | sudo tee -a /etc/graylog/server/server.conf



sudo sed -i '/web_listen_uri/s/^#//' /etc/graylog/server/server.conf
sudo sed -i "/rest_listen_uri/s/127.0.0.1/${VM_IP}/" /etc/graylog/server/server.conf
sudo sed -i "/web_listen_uri/s/127.0.0.1/${VM_IP}/" /etc/graylog/server/server.conf


## Start graylog service
sudo systemctl daemon-reload
sudo systemctl enable --now graylog-server
sudo systemctl status graylog-server