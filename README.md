# SSL Nginx
A Container-based solution that automates the process of setting up an Nginx server with SSL certificates as a service front.

With a single command, it uses Let's Encrypts Certbot inside a docker/podman container to create or renew SSL certificates and load them into Nginx.

This project simplifies the transition from HTTP to HTTPS.

Nothing other than Docker or Podman need to be installed.

# Configure

Copy conf.sh.template to conf.sh
Edit and save.

## Nginx config

Copy nginx.conf.src.template to nginx.conf.src
Edit and save

# First time start

If SSL is needed, create a certificate (optional)
./make_new_cert.sh

### Start Nginx

./start_nginx.sh

### Schedule renew of certs
