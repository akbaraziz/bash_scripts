#!/bin/bash

set -ex

sudo yum install -y https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-7-x86_64/pgdg-centos10-10-2.noarch.rpm

sudo yum install -y postgresql-server postgresql-contrib

sudo postgresql-setup initdb

sudo systemctl start postgresql
sudo systemctl enable postgresql