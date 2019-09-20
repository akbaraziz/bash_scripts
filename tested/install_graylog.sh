#!/bin/bash

set -ex

sudo rpm -Uvh https://packages.graylog2.org/repo/packages/graylog-2.0-repository_latest.rpm

sudo yum install -y graylog-server

sudo yum install -y epel-release

sudo yum install -y pwgen

sudo pwgen -N 1 -s 96
