#!/bin/bash

# Build Cache for Yum Repository
sudo dnf makecache

# Install CentOS-Stream Package
sudo dnf install -y centos-release-stream

# Replace CentOS to Stream
sudo dnf swap -y centos-{linux,stream}-repos

# Sync Repo
sudo dnf -y distro-sync