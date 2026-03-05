# SSL Nginx

A container-based solution that automates setting up an Nginx reverse proxy with SSL certificates using Let's Encrypt.

It uses Certbot inside a Docker/Podman container to create or renew SSL certificates and loads them into a containerized Nginx instance. Nothing other than Docker or Podman needs to be installed on the host.

## Overview

| Script | Purpose |
|---|---|
| `conf.sh` | Shared configuration (domain, email, paths, container engine) |
| `init_self_signed.sh` | Generates a temporary self-signed certificate for bootstrapping |
| `make_new_cert.sh` | Runs Certbot in a container to obtain a Let's Encrypt certificate |
| `start_nginx.sh` | Copies certs and starts the Nginx container |
| `renew_cert.sh` | Runs Certbot in a container to renew an existing certificate |

## How It Works

1. Nginx serves port 80 and exposes `/.well-known/acme-challenge/` from a shared webroot volume.
2. Certbot runs in a separate container using `--webroot` mode, writing its challenge files to the same shared volume.
3. Let's Encrypt validates the challenge via port 80, and Certbot writes the signed certificate to the certs volume.
4. `start_nginx.sh` copies the certificate from the Let's Encrypt `live/` directory into `current_certs/` and mounts it into Nginx for HTTPS on port 443.

## Prerequisites

- Docker or Podman installed
- Ports 80 and 443 available on the host
- A domain name pointed at the host's public IP

## Setup

### 1. Configure

Copy the template files and edit them with your values:

```bash
cp conf.sh.template conf.sh
cp nginx.conf.src.template nginx.conf.src
```

Edit `conf.sh` and set:
- `CONTAINER_ENGINE` — `docker` or `podman`
- `DOMAIN` — your domain name
- `EMAIL` — email for Let's Encrypt registration
- `ABSPATH` — absolute path to this project on the host

Edit `nginx.conf.src` to adjust proxy targets or add additional location blocks as needed.

### 2. Bootstrap with a self-signed certificate

Nginx requires an SSL certificate to start. Generate a temporary self-signed one:

```bash
./init_self_signed.sh
```

### 3. Start Nginx

Start the Nginx container. This compiles the nginx config, copies any existing certs, and launches the container:

```bash
./start_nginx.sh
```

Nginx is now running and serving the ACME challenge directory on port 80.

### 4. Obtain a Let's Encrypt certificate

With Nginx running, request a real certificate from Let's Encrypt:

```bash
./make_new_cert.sh
```

Certbot will place the challenge in the shared webroot, Let's Encrypt will validate it via port 80, and the signed certificate will be written to the certs directory.

### 5. Restart Nginx with the real certificate

Restart Nginx so it picks up the new Let's Encrypt certificate:

```bash
./start_nginx.sh
```

### 6. Schedule certificate renewal

Let's Encrypt certificates expire after 90 days. Set up a cron job to renew automatically:

```bash
# Example: attempt renewal daily at 3:00 AM and restart Nginx afterward
0 3 * * * /path/to/renew_cert.sh && /path/to/start_nginx.sh
```

After renewal, Nginx must be restarted to load the new certificate.

## Caveat

Generating the certificate from Let's Encrypt and serving on low ports (80/443) won't work out of the box with Podman. Either use Docker or configure Podman to bind to low ports via iptables or another workaround.
