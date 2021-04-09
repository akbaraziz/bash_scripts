#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/tested/install_prometheus_ubuntu.sh
# Script date: 06/05/2020
# Script ver: 1.0.0
# Script purpose: Install Prometheus on Unbuntu
# Script tested on OS: Ubuntu 20.04
#--------------------------------------------------

set -ex

VERSION=$(curl https://raw.githubusercontent.com/prometheus/prometheus/master/VERSION)

# Create a user, group and directories for Prometheus
sudo useradd -M -r -s /bin/false prometheus
sudo mkdir -p /etc/prometheus /var/lib/prometheus

# Download and extract pre-compiled binaries
wget https://github.com/prometheus/prometheus/releases/download/v${VERSION}/prometheus-${VERSION}.linux-amd64.tar.gz
tar zxf prometheus-$VERSION.linux-amd64.tar.gz prometheus-$VERSION.linux-amd64/

# Move the files to appropriate location and set ownership
sudo cp prometheus-$VERSION.linux-amd64/{prometheus,promtool} /usr/local/bin
sudo chown prometheus:prometheus /usr/local/bin/{prometheus,promtool}
sudo cp -r prometheus-$VERSION.linux-amd64/{consoles,console_libraries} /etc/prometheus/
sudo cp prometheus-$VERSION.linux-amd64/prometheus.yml /etc/prometheus/prometheus.yml
sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus

# Create a systemd unit file for Prometheus
cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus Time Series Collection and Processing Server
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

#  Reload Daemon
sudo systemctl daemon-reload

# Enable and Start Prometheus
sudo systemctl enable --now prometheus

echo "End of installation"