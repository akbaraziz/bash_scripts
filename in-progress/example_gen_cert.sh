#!/bin/bash

#Required
domain=$1
commonname=$domain

openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 \
-subj “/C=US/ST=Texas/L=Houston/O=Home Lab/CN=$domain” \
-keyout http://$domain.key -out http://$domain.cert