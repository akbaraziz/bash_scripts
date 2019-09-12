#!/bin/bash

set -ex

# Remove OS Java
sudo yum -y remove java

# Install OpenJDK
sudo yum -y install java-1.8.0-openjdk

# Create Jenkins LTS Repository
sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo
sudo rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
sudo yum -y install jenkins

# Configure Firewall Rules
firewall-cmd --permanent --service=jenkins --set-short="Jenkins Service Ports"
firewall-cmd --permanent --service=jenkins --set-description="Jenkins service firewalld port exceptions"
firewall-cmd --permanent --add-service=jenkins
firewall-cmd --zone=public --add-service=http --permanent
firewall-cmd --reload

# Set Jenkins Services 
sudo chkconfig jenkins on
sudo systemctl start jenkins

# Set a Shell for Jenkins User
sudo usermod -s /bin/bash jenkins

# Add Jenkins user to sudoers file
echo "jenkins      ALL=(ALL) NOPASSWD" | sudo tee -a /etc/sudoers > /dev/null