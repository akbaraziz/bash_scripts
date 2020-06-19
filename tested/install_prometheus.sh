#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script date: 06/05/2020
# Script ver: 1.0
# Script tested on OS: CentOS 7.x
# Script purpose: To Install Prometheus on CentOS 7 system

#--------------------------------------------------

set -ex

VERSION=$(curl https://raw.githubusercontent.com/prometheus/prometheus/master/VERSION)

#Disable SELINUX
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

# Make prometheus user
sudo useradd --no-create-home --shell /bin/false prometheus

# Make directories and dummy files necessary for prometheus
sudo mkdir -p /etc/prometheus
sudo mkdir -p /var/lib/prometheus
sudo touch /etc/prometheus/prometheus.yml
sudo touch /etc/prometheus/prometheus.rules.yml

# Assign ownership of the files above to prometheus user
sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus

# Download prometheus and copy utilities to where they should be in the filesystem
wget https://github.com/prometheus/prometheus/releases/download/v${VERSION}/prometheus-${VERSION}.linux-amd64.tar.gz
tar xvzf prometheus-${VERSION}.linux-amd64.tar.gz

sudo cp prometheus-${VERSION}.linux-amd64/prometheus /usr/local/bin/
sudo cp prometheus-${VERSION}.linux-amd64/promtool /usr/local/bin/
sudo cp -r prometheus-${VERSION}.linux-amd64/consoles /etc/prometheus
sudo cp -r prometheus-${VERSION}.linux-amd64/console_libraries /etc/prometheus

# Assign the ownership of the tools above to prometheus user
sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

# Prometheus Configuration
cat <<EOF > /etc/prometheus/prometheus.yml
global:
    scrape_interval: 10s

scrape_configs:
    -job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
        -targets: ['localhost:9090']
EOF
sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml

# Create Prometheus as a Service
cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus Server
Wants=network-online.target
After=network-online.target
 
[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries
 
[Install]
WantedBy=multi-user.target
EOF

# Enable and Start Services
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus

# Add Firewall Rules if Running
if [ `systemctl is-active firewalld` ]
then
    firewall-cmd --zone=public --add-port=9090/tcp --permanent && firewall-cmd --reload
else
    firewall_status=inactive
fi

# Installation cleanup
rm prometheus-${VERSION}.linux-amd64.tar.gz
rm -rf prometheus-${VERSION}.linux-amd64

# Application Info
echo "Prometheus URL: http://$hostname:9090/graph"
