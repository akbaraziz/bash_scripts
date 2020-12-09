#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script date: 12/09/2020
# Script ver: 1.0
# Script tested on OS: CentOS 7.x
# Script purpose: To install Elastic Search

#--------------------------------------------------

set -ex

#Import ElasticSearch PGP Key
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

#Create RPM Repository
cat >/etc/yum.repos.d/elasticsearch.repo <<EOL 
[elasticsearch]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=0
autorefresh=1
type=rpm-md
EOL

# Disable Swap
if [ $? -eq 0 ]; then
	echo 'swapfile found. Removing swapfile.'
	sed -i '/ swap/ s/^/#/' /etc/fstab
	echo "3" > /proc/sys/vm/drop_caches
	swapoff -a
	rm -f /swapfile
fi

# Increase Virtual Memory
sudo sysctl -w vm.max_map_count=262144

# Install Java OpenJDK
sudo yum -y install java-1.8.0-openjdk

# Install ElasticSearch
sudo yum -y  install --enablerepo=elasticsearch elasticsearch

# Add Firewall Rules
sudo firewall-cmd --new-zone=elasticsearch --permanent
sudo firewall-cmd --reload
sudo firewall-cmd --zone=elasticsearch --add-source=@@{address}@@/32 --permanent
sudo firewall-cmd --zone=elasticsearch --add-port=9200/tcp --permanent
sudo firewall-cmd --reload

# Start and Enable ElasticSearch
sudo systemctl enable --now elasticsearch

# Verify ElasticSearch is working
curl -X GET "localhost:9200/"

exit 0