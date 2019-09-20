#!/bin/bash

set -ex

sudo firewall-cmd --permanent --zone=public --add-port=22/tcp
sudo firewall-cmd --reload