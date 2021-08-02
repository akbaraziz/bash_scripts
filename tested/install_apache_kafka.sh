#!/bin/sh

set -ex

# Set Firewall Rules
if [ "$(systemctl is-active firewalld)" ]
then
    sudo firewall-cmd --zone=public --permanent --add-port=9092/tcp
    sudo firewall-cmd --zone=public --permanent --add-port=2181/tcp
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

# Remove Existing Version of Java if installed
if rpm -qa | grep -q java*; then
    yum remove -y java*;
else
    echo Not Installed
fi

# Install Java
sudo yum -y install java-1.8.0-open-jdk

# Download and Install Kafka
wget https://downloads.apache.org/kafka/2.8.0/kafka_2.13-2.8.0.tgz
sudo tar -xzf kafka_2.13-2.8.0.tgz
sudo ln -s kafka_2.13-2.8.0 kafka
sudo /root/kafka/bin/zookeeper-server-start.sh config/zookeeper.properties
sudo /root/kafka/bin/kafka-server-start.sh config/server.properties
sudo /root/kafka/bin/kafka-topics.sh --create --topic quickstart-events --bootstrap-server localhost:9092
echo "export PATH=$PATH:/root/kafka_2.13-2.8.0/bin" >> ~/.bash_profile
sudo source ~/.bash_profile
sudo zookeeper-server-start.sh -daemon /root/kafka/config/zookeeper.properties
sudo kafka-server-start.sh -daemon /root/kafka/config/server.properties

# Create a Topic
sudo kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic @@{TOPIC}@@

# List Topics
sudo kafka-topics.sh --zookeeper localhost:2181 --list