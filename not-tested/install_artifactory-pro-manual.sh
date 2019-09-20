#!/bin/bash

set -ex  

# Install Java
sudo yum remove -y java
sudo yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel

export JAVA_HOME=$(dirname $(dirname $(readlink $(readlink $(which javac)))))
source ~/.bashrc
echo $JAVA_HOME
export PATH=$PATH:$JAVA_HOME/bin
export CLASSPATH=.:$JAVA_HOME/jre/lib:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar
source ~/.bashrc

# Install MariaDB
cat <<EOF | sudo tee /etc/yum.repos.d/MariaDB.repo
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.3/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF

yum install -y MariaDB-server MariaDB-client

systemctl start mariadb && systemctl enable mariadb


wget https://bintray.com/jfrog/artifactory-pro-rpms/rpm -O bintray-jfrog-artifactory-pro-rpms.repo

sudo mv bintray-jfrog-artifactory-pro-rpms.repo /etc/yum.repos.d/

yum install -y jfrog-artifactory-pro

# Set Artifactory Home
echo "export ARTIFACTORY_HOME=/opt/jfrog/artifactory" | sudo tee -a /etc/profile
source /etc/profile
env | grep ARTIFACTORY_HOME

# Configure Artifactory to use MariaDB
mkdir -p /var/opt/jfrog/artifactory/etc
cp /opt/jfrog/artifactory/misc/db/mariadb.properties /var/opt/jfrog/artifactory/etc/db.properties
sh /opt/jfrog/artifactory/bin/configure.mysql.sh