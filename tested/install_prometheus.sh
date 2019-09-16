#!/bin/bash

set -ex

# Make prometheus user
sudo adduser --no-create-home --shell /bin/false prometheus

# Make directories and dummy files necessary for prometheus
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
sudo touch /etc/prometheus/prometheus.yml
sudo touch /etc/prometheus/prometheus.rules.yml

# Assign ownership of the files above to prometheus user
sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus

# Firewall Rules
if [ `systemctl is-active firewalld` ]
then
    firewall-cmd --zone=public --add-port=9090/tcp --permanent && firewall-cmd --reload
else
    firewall_status=inactive
fi

# Download prometheus and copy utilities to where they should be in the filesystem
#VERSION=2.11.1
VERSION=$(curl https://raw.githubusercontent.com/prometheus/prometheus/master/VERSION)
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

# Prometheus Services
cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
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

# Installation cleanup
rm prometheus-${VERSION}.linux-amd64.tar.gz
rm -rf prometheus-${VERSION}.linux-amd64

