#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script date: 11/30/2020
# Script ver: 1.1
# Script tested on OS: CentOS 7.x
# Script purpose: Install Jenkins

#--------------------------------------------------

#!/bin/bash
set -ex

sudo yum install -y wget

#Import jenkins-ci rpm and install jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
sudo yum install -y jenkins

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