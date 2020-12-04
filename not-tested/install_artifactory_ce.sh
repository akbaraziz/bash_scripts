
#!/bin/bash

set -ex  

# Install Java
sudo yum remove -y java
sudo yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel

# Set JAVA_HOME
export JAVA_HOME=$(dirname $(dirname $(readlink $(readlink $(which javac)))))
source ~/.bashrc
echo $JAVA_HOME
export PATH=$PATH:$JAVA_HOME/bin
export CLASSPATH=.:$JAVA_HOME/jre/lib:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar
source ~/.bashrc

# Download and Create Artifactory CE Repo
wget https://bintray.com/jfrog/artifactory-rpms/rpm -O bintray-jfrog-artifactory-oss-rpms.repo;
sudo mv  bintray-jfrog-artifactory-oss-rpms.repo /etc/yum.repos.d/;

# Install Artifactory CE
yum install jfrog-artifactory-oss -y

# Start and Enable Artifactory
sudo systemctl start artifactory
sudo systemctl enable artifactory