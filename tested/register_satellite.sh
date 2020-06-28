#/bin/bash

set -ex

# Register to Satellite or RHN
subscription-manager register --username=admin --password=secret --org=organization_label --auto-attach
echo
echo

# Check license used by host
subscription-manager list --consumed