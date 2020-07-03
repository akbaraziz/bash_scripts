#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script date: 06/05/2020
# Script ver: 1.0
# Script tested on OS: CentOS 7.x
# Script purpose: Install Jenkins

#--------------------------------------------------

set -ex

# Remove Existing Version of Java if installed
if rpm -qa | grep -q java*; then
    yum remove -y java*;
else
    echo Not Installed
fi

# Install OpenJDK
sudo yum -y install java-1.8.0-openjdk

# Create Jenkins LTS Repository
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

# Install Jenkins
sudo yum -y install jenkins

# Enable and Start Jenkins Services 
sudo chkconfig jenkins on
sudo systemctl start jenkins

# Set a Shell for Jenkins User
sudo usermod -s /bin/bash jenkins

# Add Jenkins user to sudoers file
echo "jenkins      ALL=(ALL) NOPASSWD" | sudo tee -a /etc/sudoers > /dev/null

# Add Firewall Rules if Running
if [ `systemctl is-active firewalld` ]
then
    firewall-cmd --permanent --service=jenkins --set-short="Jenkins Service Ports"
    firewall-cmd --permanent --service=jenkins --set-description="Jenkins service firewalld port exceptions"
    firewall-cmd --permanent --add-service=jenkins
    firewall-cmd --permanent --zone=public --add-service=http 
    firewall-cmd --reload
else
    firewall_status=inactive
fi

# Get auth password from Jenkins
echo "authpwd="$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)