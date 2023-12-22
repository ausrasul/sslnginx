#!/bin/bash

source "$(dirname "$0")/conf.sh"

# Define the name of the Docker container
CONTAINER_NAME="nginx_container"

# Define the path to your local Nginx configuration file

cp ${SSL_CERT_DIR}/live/*/* ${SSL_CERT_CURRENT}/

# Stop and remove the Docker container if it already exists
if [ $(docker ps -a -f name=$CONTAINER_NAME | grep -w $CONTAINER_NAME | wc -l) -eq 1 ]; then
  echo "Stopping and removing existing container..."
  docker stop $CONTAINER_NAME
  docker rm $CONTAINER_NAME
fi

# Start a new Docker container with the Nginx image
echo "Starting new Nginx container..."
docker run --name $CONTAINER_NAME \
	-d \
	-p 80:80 \
	-p 443:443 \
	-v $NGINX_CONFIG:/etc/nginx/nginx.conf:ro \
	-v $SSL_CERT_CURRENT:/ssl:ro \
	-v $SSL_WEBROOT:/webroot \
	nginx

