#!/bin/bash

source ./all-env.sh

# Install NGINX
sudo apt-get install nginx

# Create NGINX Server Block for Mattermost
sudo cp /path/to/mattermost/nginx.conf ${NGINX_SITE_CONFIG}
# Make sure to edit the nginx.conf file to suit your configuration

# Enable NGINX Configuration
sudo ln -s /etc/nginx/sites-available/mattermost /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Install Certbot and Setup SSL
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d ${LETSENCRYPT_DOMAIN} --agree-tos --email ${LETSENCRYPT_EMAIL} --redirect --non-interactive
