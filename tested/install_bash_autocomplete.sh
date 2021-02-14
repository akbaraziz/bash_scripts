#!/bin/bash

set -ex

# Create EPEL Repository
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

sudo yum install -y bash-completion bash-completion-extras