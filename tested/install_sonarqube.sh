#!/bin/bash

set -ex

psqluser=@@{SonarAdmin.username}@@   # Database username
psqlpass='@@{SonarAdmin.secret}@@'  # Database password
psqldb=@@{SONAR_DB_NAME}@@   # Database name

# Disable SELinux
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Update Sysctl Config
echo '
vm.max_map_count=524288
fs.file-max=131072' | sudo tee -a /etc/sysctl.conf
sudo sysctl --system

echo '
ulimit -n 131072
ulimit -u 8192' | sudo tee -a /etc/security/limits.conf

# Add Sonar User
sudo useradd "@@{SonarAdmin.username}@@" -p "@@{SonarAdmin.secret}@@"

# Install Java
sudo yum install -y java-11-openjdk-devel

# Install PostgreSQL
sudo yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
sudo yum clean all
sudo yum install -y postgresql13-server
sudo /usr/pgsql-13/bin/postgresql-13-setup initdb
sudo systemctl enable --now postgresql-13

sudo printf "CREATE USER $psqluser WITH PASSWORD '$psqlpass';\nCREATE DATABASE $psqldb WITH OWNER $psqluser;\ngrant all privileges on database $psqldb to $psqluser;\nALTER USER $psqluser WITH ENCRYPTED password $psqlpass;" > /var/tmp/@@{SONAR_DB_NAME}@@.sql
sudo chmod +x /var/tmp/@@{SONAR_DB_NAME}@@.sql
sudo -u postgres psql -f /var/tmp/@@{SONAR_DB_NAME}@@.sql

# Install SonarQube
cd /opt
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.0.1.46107.zip
sudo yum -y install unzip
sudo unzip -qq sonarqube-9.0.1.46107.zip
sudo mv sonarqube-9.0.1.46107 sonarqube

# Configure SonarQube
echo '
\##Database details
sonar.jdbc.username=$psqluser
sonar.jdbc.password=$psqlpass
sonar.jdbc.url=jdbc:postgresql://localhost/$psqldb

\##How you will access SonarQube Web UI
sonar.web.host="@@{address}@@"
sonar.web.port=9000

\##Java options
sonar.web.javaOpts=-Xmx512m -Xms128m -XX:+HeapDumpOnOutOfMemoryError
sonar.search.javaOpts=-Xmx512m -Xms512m -XX:MaxDirectMemorySize=256m -XX:+HeapDumpOnOutOfMemoryError

\##Also uncomment the following Elasticsearch storage paths
sonar.path.data=data
sonar.path.temp=temp' | sudo tee -a /opt/sonarqube/conf/sonar.properties
sudo chown -R "@@{SonarAdmin.username}@@":"@@{SonarAdmin.username}@@" /opt/sonarqube

echo '
wrapper.java.command=/usr/local/jdk-11.0.2/bin/java' | sudo tee -a /opt/sonarqube/conf/wrapper.conf

echo '
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=simple
User=sonarqube
Group=sonarqube
PermissionsStartOnly=true
ExecStart=/bin/nohup /opt/java/bin/java -Xms32m -Xmx32m -Djava.net.preferIPv4Stack=true -jar /opt/sonarqube/lib/sonar-application-9.0.1.46107.jar
StandardOutput=syslog
LimitNOFILE=131072
LimitNPROC=8192
TimeoutStartSec=5
Restart=always
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target' | sudo tee /etc/systemd/system/sonarqube.service

sudo systemctl daemon-reload

# Start SonarQube Service
sudo systemctl enable --now sonarqube.service

# Add Firewall Rules for SonarQube
sudo firewall-cmd --permanent --add-port=9000/tcp && sudo firewall-cmd --reload

# Application URL
echo Application URL: http://@@{address}@@:9000
echo Default user name - admin
echo Default user password - admin