#!/bin/bash

set -ex

SERVICE=firewalld

systemctl is-active --quiet $SERVICE && echo $SERVICE is running