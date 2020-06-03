#!/bin/bash

set -ex

# Copy SSH Keys to Remote Server 
sshpass -p "PASSWORD" ssh-copy-id -o StrictHostKeyChecking=no USERNAME@IP