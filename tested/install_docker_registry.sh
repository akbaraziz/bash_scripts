#!/bin/bash

set -ex

sudo yum install -y httpd-utils

echo "Creating docker-registry directory..."
sudo mkdir -p /docker-registry/data
sudo mkdir -p /docker-registry/nginx

echo "Creating docker-registry.yml file..."
echo 'nginx:
  image: "nginx:1.9"
  ports:
    - 443:443
  links:
    - registry:registry
  volumes:
    - ./nginx/:/etc/nginx/conf.d
registry:
  image: registry:2
  ports:
    - 127.0.0.1:5000:5000
  environment:
    REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY: /data
  volumes:
- ./data:/data' | sudo tee /docker-registry/docker-compose.yml

echo 'upstream docker-registry {
  server registry:5000;
}

server {
  listen 443;
  server_name @@{HOST_NAME}@@.@@{DOMAIN_NAME}@@;

  # SSL
  ssl on;
  ssl_certificate /etc/nginx/conf.d/domain.crt;
  ssl_certificate_key /etc/nginx/conf.d/domain.key;

  # disable any limits to avoid HTTP 413 for large image uploads
  client_max_body_size 0;

  # required to avoid HTTP 411: see Issue #1486 (https://github.com/docker/docker/issues/1486)
  chunked_transfer_encoding on;

  location /v2/ {
    # Do not allow connections from docker 1.5 and earlier
    if ($http_user_agent ~ "^(docker\/1\.(3|4|5(?!\.[0-9]-dev))|Go ).*$" ) {
      return 404;
    }

    # To add basic authentication to v2 use auth_basic setting plus add_header
    auth_basic "registry.localhost";
    auth_basic_user_file /etc/nginx/conf.d/registry.password;
    add_header "Docker-Distribution-Api-Version" "registry/2.0" always;

    proxy_pass                          http://docker-registry;
    proxy_set_header  Host              $http_host;
    proxy_set_header  X-Real-IP         $remote_addr;
    proxy_set_header  X-Forwarded-For   $proxy_add_x_forwarded_for;
    proxy_set_header  X-Forwarded-Proto $scheme;
    proxy_read_timeout                  900;
  }
}' | sudo tee /docker-registry/nginx/registry.conf

echo "Create Docker Cert"
echo @@{DockerAdmin.secret}@@ | sudo htpasswd -ci /docker-registry/nginx/registry.password @@{DockerAdmin.username}@@

sudo openssl genrsa -out /docker-registry/nginx/devdockerCA.key 2048

sudo openssl req -x509 -new -nodes -key /docker-registry/nginx/devdockerCA.key -days 10000 -out /docker-registry/nginx/devdockerCA.crt -subj "/C=US/ST=California/L=San Jose/O=nutnaix/OU=DevOps/CN=@@{HOST_NAME}@@.@@{DOMAIN_NAME}@@/emailAddress=''"

sudo openssl genrsa -out /docker-registry/nginx/domain.key 2048

sudo openssl req -new -key /docker-registry/nginx/domain.key -out /docker-registry/nginx/dev-docker-registry.com.csr -subj "/C=US/ST=California/L=San Jose/O=nutnaix/OU=DevOps/CN=@@{name}@@.@@{domain_name}@@/emailAddress=''"

sudo openssl x509 -req -in /docker-registry/nginx/dev-docker-registry.com.csr -CA /docker-registry/nginx/devdockerCA.crt -CAkey /docker-registry/nginx/devdockerCA.key -CAcreateserial -out /docker-registry/nginx/domain.crt -days 10000

sudo cp /docker-registry/nginx/devdockerCA.crt /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust

sudo systemctl enable docker

echo "Restart Docker Service"
sudo service docker restart

echo "Creating Init Script"
echo '[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/docker-compose -f /docker-registry/docker-compose.yml up -d
ExecReload=/bin/kill -s HUP $MAINPID
LimitNOFILE=1048576
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity
# Uncomment TasksMax if your systemd version supports it.
# Only systemd 226 and above support this version.
TasksMax=infinity
TimeoutStartSec=0
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process
# restart the docker process if it exits prematurely
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s

[Install]
WantedBy=multi-user.target' | sudo tee /etc/systemd/system/docker-registry.service

sudo systemctl enable docker-registry

echo "Starting docker-registry Service"
sudo service docker-registry start

echo "Configure Docker Registry"
mkdir ~/.ssh
chmod 700 ~/.ssh
echo "@@{LocalAdmin.secret}@@" > ~/.ssh/id_rsa
echo "@@{LocalAdmin_public_key}@@" > ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/*
sudo cp /docker-registry/nginx/devdockerCA.crt ~/
sudo chown @@{LocalAdmin.username}@@:@@{LocalAdmin.username}@@ ~/devdockerCA.crt
chmod 600 ~/devdockerCA.crt
echo "set -o vi" >> ~/.bashrc
