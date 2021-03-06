#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/tested/install_rabbitmq.sh
# Script date: 06/05/2020
# Script ver: 1.0.0
# Script purpose: Install RabbitMQ
# Script tested on OS: CentOS 7.x
#--------------------------------------------------

set -ex

MQ_VER=v3.7.15-1.el7
ER_VER=22.0.7-1.el7
MQ_ADMIN=mqadmin
MQ_ADMIN_PASSWORD=P@ssword1

# Dowloading the RabbitMQ Repo Key
wget https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc
rpm --import rabbitmq-release-signing-key.asc

# Adding ERLANG Repository
cat > /etc/yum.repos.d/rabbitmq-erlang.repo <<EOL
[rabbitmq-erlang]
name=rabbitmq-erlang
baseurl=https://dl.bintray.com/rabbitmq-erlang/rpm/erlang/21/el/7
gpgcheck=1
gpgkey=https://dl.bintray.com/rabbitmq/Keys/rabbitmq-release-signing-key.asc
repo_gpgcheck=0
enabled=1
EOL

# Installing ERLANG for RabbitMQ
yum install erlang-$ER_VER -y --quiet

# Adding RabbitMQ Repository
cat > /etc/yum.repos.d/rabbitmq.repo <<EOL
[bintray-rabbitmq-server]
name=bintray-rabbitmq-rpm
baseurl=https://dl.bintray.com/rabbitmq/rpm/rabbitmq-server/${MQ_VER}/el/7/
gpgcheck=0
repo_gpgcheck=0
enabled=1
EOL

# Installing RabbitMQ
sudo yum install rabbitmq-server-${MQ_VER} -y --quiet

# Add Firewall Rules if Running
if [ `systemctl is-active firewalld` ]
then
    firewall-cmd --zone=public --permanent --add-port=4369/tcp --add-port=25672/tcp --add-port=5671-5672/tcp --add-port=15672/tcp  --add-port=61613-61614/tcp --add-port=1883/tcp --add-port=8883/tcp
    firewall-cmd --reload
else
    firewall_status=inactive
fi

# Enable and Start RabbitMQ Service
systemctl enable --now rabbitmq-server

# Configure Management Console
echo "Enable RabbitMQ Management Console..."
rabbitmq-plugins enable rabbitmq_management
chown -R rabbitmq:rabbitmq /var/lib/rabbitmq/

# Adding RabbitMQ User and Tags
rabbitmqctl add_user $MQ_ADMIN $MQ_ADMIN_PASSWORD
rabbitmqctl set_user_tags $MQ_ADMIN administrator
rabbitmqctl set_permissions -p / $MQ_ADMIN ".*" ".*" ".*"