#!/bin/bash

source "$(dirname "$0")/conf.sh"
openssl req -new -x509 -key <(openssl genrsa |tee  ${SSL_CERT_CURRENT}/privkey.pem) -out ${SSL_CERT_CURRENT}/fullchain.pem -subj "/CN=${DOMAIN}"