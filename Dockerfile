# Stage 1: Build PHP dependencies (if you add backend features)
FROM composer:2 AS composer_build
WORKDIR /app
COPY composer.json composer.lock* ./
RUN mkdir -p lib/composer && composer install --no-dev --ignore-platform-reqs || true

# Stage 2: Build Javascript/Vue UI assets (if you modify the UI)
FROM node:24 AS node_build
WORKDIR /app
# Copy the rest of the Nextcloud source first so demi.sh and other required files exist for postinstall
COPY . .
# Install node modules
RUN npm ci --ignore-scripts || npm install --ignore-scripts
# Run postinstall scripts now if any
RUN npm rebuild || true
# Compile the Javascript/CSS assets
RUN npm run build || echo "Build script not found or failed, continuing..."

# Stage 3: Final Production Image
# We layer your compiled web assets on top of the official image
FROM nextcloud:30-apache
COPY --from=node_build /app /var/www/html/
# Safely copy composer dependencies
COPY --from=composer_build /app/lib/composer /var/www/html/lib/composer
RUN chown -R www-data:www-data /var/www/html
