#!/bin/bash

set -ex

# Download and Install Erlang
sudo yum install -y epel-release
sudo rpm -Uvh https://packages.erlang-solutions.com/erlang-solutions-1.0-1.noarch.rpm
sudo yum install -y --quiet erlang

# Download and Install RabbitMQ
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash
sudo yum install -y rabbitmq-server

# Configure RabbitMQ
echo '
tcp_listen_options.backlog       = 128
tcp_listen_options.nodelay       = true
tcp_listen_options.exit_on_close = false
tcp_listen_options.keepalive     = false

heartbeat = 580' | sudo tee -a /etc/rabbitmq/rabbitmq.conf

# Set Firewall Rules
if [ "$(systemctl is-active firewalld)" ]
then
    sudo firewall-cmd --zone=public --permanent --add-port=4369/tcp
    sudo firewall-cmd --zone=public --permanent --add-port=25672/tcp
    sudo firewall-cmd --zone=public --permanent --add-port=5671-5672/tcp
    sudo firewall-cmd --zone=public --permanent --add-port=15672/tcp
    sudo firewall-cmd --zone=public --permanent --add-port=61613-61614/tcp
    sudo firewall-cmd --zone=public --permanent --add-port=1883/tcp
    sudo firewall-cmd --zone=public --permanent --add-port=8883/tcp
    sudo firewall-cmd --reload
else
    echo "Firewall is not running"
fi

# Configure SELinux
selinuxenabled
if [ $? -ne 0 ]
then 
    echo "SELINUX is DISABLED"
else
    sudo setsebool -P nis_enabled 1
fi

# Start and Enable RabbitMQ
sudo systemctl enable --now rabbitmq-server

# Enable RabbitMQ Web Console
sudo rabbitmq-plugins enable rabbitmq_management
sudo chown -R rabbitmq:rabbitmq /var/lib/rabbitmq/

# Adding RabbitMQ User and Tags
sudo rabbitmqctl add_user @@{MqAdmin.username}@@ @@{MqAdmin.secret}@@
sudo rabbitmqctl set_user_tags @@{MqAdmin.username}@@ administrator
sudo rabbitmqctl set_permissions -p / @@{MqAdmin.username}@@ ".*" ".*" ".*"
sudo rabbitmqctl delete_user guest
sudo systemctl restart rabbitmq-server