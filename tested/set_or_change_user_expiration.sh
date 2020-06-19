#!/bin/bash

set -ex

# Check Password Age for User
chage -l username

# Set Account Expiration Date
chage -E "YYYY-MM-DD" username 

# Disable Password Aging for User
chage -m 0 -M 9999 -I -1 -E -1 username