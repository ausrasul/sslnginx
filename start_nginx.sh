#!/bin/bash

source "$(dirname "$0")/conf.sh"

# Define the name of the Docker/Podman container
CONTAINER_NAME="nginx_container"

NGINX_CONFIG_SRC="$(dirname "$0")/nginx.conf.src"
NGINX_CONFIG_COMPILED="$(dirname "$0")/nginx.conf"

# Copy certs from Let's Encrypt live directory to current_certs.
# The live directory is owned by root (created by certbot container),
# so we use a container to perform the copy.

if [ -d "${SSL_CERT_DIR}/live" ]; then
	$CONTAINER_ENGINE run --rm \
		-v "${SSL_CERT_DIR}:/etc/letsencrypt:ro" \
		-v "${SSL_CERT_CURRENT}:/out" \
		alpine sh -c 'cp /etc/letsencrypt/live/*/* /out/ 2>/dev/null'
else
	echo "Warning: Couldn't find letsencrypt certs under ${SSL_CERT_DIR}/live"
fi

# Process nginx.conf.template with environment variables
export DOMAIN
envsubst '$DOMAIN' < ${NGINX_CONFIG_SRC} > ${NGINX_CONFIG_COMPILED}

# Stop and remove the Docker/Podman container if it already exists
if [ $($CONTAINER_ENGINE ps -a -f name=$CONTAINER_NAME | grep -w $CONTAINER_NAME | wc -l) -eq 1 ]; then
  echo "Stopping and removing existing container..."
  $CONTAINER_ENGINE stop $CONTAINER_NAME
  $CONTAINER_ENGINE rm $CONTAINER_NAME
fi

# Start a new Docker/Podman container with the Nginx image
echo "Starting new Nginx container..."
$CONTAINER_ENGINE run --name $CONTAINER_NAME \
	-d \
	-p 80:80 \
	-p 443:443 \
	-v $NGINX_CONFIG:/etc/nginx/nginx.conf:ro \
	-v $SSL_CERT_CURRENT:/ssl:ro \
	-v $SSL_WEBROOT:/webroot \
	nginx

