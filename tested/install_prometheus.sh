#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script date: 03/31/2021
# Script ver: 1.1
# Script tested on OS: CentOS 7.8
# Script purpose: Install Prometheus on CentOS

#--------------------------------------------------

set -ex

VERSION=$(curl https://raw.githubusercontent.com/prometheus/prometheus/master/VERSION)

# Create a user, group and directories for Prometheus
sudo groupadd --system prometheus
sudo useradd -s /sbin/nologin --system -g prometheus prometheus
sudo mkdir -p /var/lib/prometheus
for i in rules rules.d files_sd; do sudo mkdir -p /etc/prometheus/${i}; done

# Download and extract pre-compiled binaries
wget https://github.com/prometheus/prometheus/releases/download/v${VERSION}/prometheus-${VERSION}.linux-amd64.tar.gz
tar zxf prometheus-$VERSION.linux-amd64.tar.gz prometheus-$VERSION.linux-amd64/

# Move the files to appropriate location and set ownership
sudo cp prometheus-$VERSION.linux-amd64/{prometheus,promtool} /usr/local/bin
sudo chown prometheus:prometheus /usr/local/bin/{prometheus,promtool}
sudo cp -r prometheus-$VERSION.linux-amd64/{consoles,console_libraries} /etc/prometheus/
sudo cp prometheus-$VERSION.linux-amd64/prometheus.yml /etc/prometheus/prometheus.yml
sudo mv consoles/ console_libraries/ /etc/prometheus/
sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus

# Create a Prometheus Configuration File
cat <<EOF > /etc/prometheus/prometheus.yml 
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
    - targets: ['localhost:9090']
EOF

# Create a systemd unit file for Prometheus
cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Documentation=https://prometheus.io/docs/introduction/overview/
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
Environment="GOMAXPROCS=2"
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.listen-address=0.0.0.0:9090 \
  --web.external-url=

SyslogIdentifier=prometheus
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Change Directory Permissions
for i in rules rules.d files_sd; do sudo chown -R prometheus:prometheus /etc/prometheus/${i}; done
for i in rules rules.d files_sd; do sudo chmod -R 775 /etc/prometheus/${i}; done
sudo chown -R prometheus:prometheus /var/lib/prometheus/

# Enable and Start Prometheus
sudo systemctl daemon-reload 
sudo systemctl enable --now prometheus

# Configure Firewalld
sudo firewall-cmd --add-port=9090/tcp --permanent
sudo firewall-cmd --reload

echo "End of installation"