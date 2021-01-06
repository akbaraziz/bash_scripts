#!/bin/bash

set -ex

# Clear Linux Info
/bin/find /var/log/ -type f -exec /bin/sh -c '>{}' \;