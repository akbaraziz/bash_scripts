#!/usr/bin/bash

set -ex

echo 'foobar ALL=(ALL:ALL) ALL' | sudo -S EDITOR='tee -a' visudo