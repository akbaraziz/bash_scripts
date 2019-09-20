#!/bin/bash

set -ex

sudo rpm -Uvh https://packages.graylog2.org/repo/packages/graylog-2.0-repository_latest.rpm

sudo yum install graylog-server -y

sudo yum install epel-release -y

sudo yum install pwgen -y

sudo pwgen -N 1 -s 96
