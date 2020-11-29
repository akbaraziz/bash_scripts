#!/bin/bash

set -ex

# Enable Repository
sudo yum install centos-release-scl -y

# Install Python 3
sudo yum install rh-python36 -y

# Enable Python
sudo scl enable rh-python36 bash

# Create Directory
mkdir tensorflow_project
cd tensorflow_project
python3 -m venv venv

# Activate Venv
source venv/bin/activate

# Install TensorFlow
pip install --upgrade pip
pip install --upgrade tensorflow

# Confirm Version
python -c 'import tensorflow as tf; print(tf.__version__)'