#!/bin/bash

set -ex

# Variables Used
REDIS_PASSWORD="@@{REDIS_PASSWORD}@@"

# Create seperate vg for redis storage
sudo mkdir -p /var/lib/redis
sudo yum install -y lvm2
sudo pvcreate /dev/sdb
sudo vgcreate redis_vg /dev/sdb
sleep 3
sudo lvcreate -l 100%VG -n redis_lvm redis_vg
sudo mkfs.xfs /dev/redis_vg/redis_lvm
echo -e "/dev/redis_vg/redis_lvm \t /var/lib/redis \t xfs \t defaults \t 0 0" | sudo tee -a /etc/fstab
sudo mount -a

# Download and Install Redis
sudo yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
sudo yum --enablerepo=remi install redis -y

# Set Firewall Rules
sudo firewall-cmd --permanent --add-port=6379/tcp
sudo firewall-cmd --reload

# Configure Redis
echo "supervised systemd" | sudo tee -a /etc/redis.conf
echo "requirepass ${REDIS_PASSWORD}" | sudo tee -a /etc/redis.conf
echo "maxmemory-policy noeviction" | sudo tee -a /etc/redis.conf
sudo sed -i 's/daemonize no/daemonize yes/g' /etc/redis.conf
sudo sed -i 's/bind 127.0.0.1 -::1/bind @@{address}@@ -::1/g' /etc/redis.conf
sudo sed -i 's/appendonly no/appendonly yes/' /etc/redis.conf
sudo sed -i 's/appendfilename "appendonly.aof"/appendfilename redis-staging-ao.aof/' /etc/redis.conf

# Enable and Start Redis Service
sudo systemctl enable --now redis