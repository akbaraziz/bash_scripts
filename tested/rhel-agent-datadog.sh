#!/bin/bash

set -ex

DD_API_KEY=966c5376ab727a82ed299ed7c02a6c19 bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/datadog-agent/master/cmd/agent/install_script.sh)"