FROM php:8.2-apache-buster AS builder

# This Dockerfile is a starting point for building your custom Nextcloud core!
# Nextcloud core development requires Composer and Node.js for assets.
# If you make changes to core PHP, they will be copied over.

# In production, you would compile assets here. To get started quickly, 
# we layer your server repository over the official Nextcloud image.
FROM nextcloud:latest
# Warning: Doing a raw COPY . /var/www/html will overwrite compiled assets 
# unless you build them. We recommend developing Nextcloud Apps instead 
# of modifying the core directly, but if you do modify the core, ensure 
# your CI/CD builds the complete php/js assets.
COPY custom.ini /usr/local/etc/php/conf.d/
