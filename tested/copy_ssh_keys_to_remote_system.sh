#!/bin/bash
# To copy id_rsa.pub file to remote linux system. "SSHPASS must be installed before executing."
# Created by: Akbar Aziz
# Date: 06/05/2020
# Version: 1.0


set -ex

# Copy SSH Keys to Remote Server 
sshpass -p "PASSWORD" ssh-copy-id -o StrictHostKeyChecking=no USERNAME@IP