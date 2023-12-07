#!/bin/bash

# Export MySQL Variables
export MYSQL_USER='mmuser'
export MYSQL_PASSWORD='mmuser-password'
export MYSQL_DATABASE='mattermost'

# Export Mattermost Variables
export MATTERMOST_VERSION='latest' # or specific version
export MATTERMOST_DIR='/opt/mattermost'

# Export NGINX Variables
export NGINX_SITE_CONFIG='/etc/nginx/sites-available/mattermost'
export LETSENCRYPT_DOMAIN='example.com' # Replace with your domain
export LETSENCRYPT_EMAIL='email@example.com' # Replace with your email

# Optionally, you can also export PATH or other system variables if needed