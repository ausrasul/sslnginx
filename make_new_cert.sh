#!/bin/bash
source /home/aus/nginx/conf.sh

# Start a Certbot container using Podman
podman run -it --rm --name certbot \
    -v "${SSL_CERT_DIR}:/etc/letsencrypt" \
    -v "${SSL_LIB}:/var/lib/letsencrypt" \
    -v "${SSL_WEBROOT}:/var/www/html" \
    certbot/certbot certonly \
    --webroot -w /var/www/html -d ${DOMAIN} \
    --email ${EMAIL} --agree-tos --no-eff-email -v

