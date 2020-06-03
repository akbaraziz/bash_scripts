#!/bin/bash

set -ex

# Create CouchDB Repository
cat >/etc/yum.repos.d/bintray-apache-couchdb-rpm.repo <<EOL
[bintray--apache-couchdb-rpm]
name=bintray--apache-couchdb-rpm
baseurl=http://apache.bintray.com/couchdb-rpm/el$releasever/$basearch/
gpgcheck=0
repo_gpgcheck=0
enabled=1
EOL

# Install CouchDB
sudo yum install -y couchdb

# Enable and Start CouchDB
sudo systemctl start couchdb
sudo systemctl enable couchdb

# Create Admin Account
cat >/opt/couchdb/etc/local.ini <<EOL
[admins]
admin = P@ssword1
EOL

# Restart CouchDB Service
sudo systemctl restart couchdb

echo App URL: "http://$HOSTNAME:5984/_utils"