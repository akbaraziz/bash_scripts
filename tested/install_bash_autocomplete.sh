#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/blob/master/tested/install_bash_autocomplete.sh
# Script date: 06/05/2020
# Script ver: 1.0.0
# Script purpose: To install bash completion
# Script tested on OS: CentOS and Redhat 7.x
#--------------------------------------------------

set -ex

# Create EPEL Repository
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm --quiet

sudo yum install -y bash-completion bash-completion-extras --quiet