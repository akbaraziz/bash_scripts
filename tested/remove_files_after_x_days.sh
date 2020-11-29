#!/bin/bash

set -ex

# Add Directory Path to command
find /path/to/files* -mtime +7 -exec rm {} ;