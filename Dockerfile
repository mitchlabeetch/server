# Stage 1: Build PHP dependencies (if you add backend features)
FROM composer:2 AS composer_build
WORKDIR /app
COPY composer.json composer.lock* ./
RUN composer install --no-dev --ignore-platform-reqs || true

# Stage 2: Build Javascript/Vue UI assets (if you modify the UI)
FROM node:20 AS node_build
WORKDIR /app
COPY package.json package-lock.json* ./
# Install node modules
RUN npm ci || npm install
# Copy the rest of the Nextcloud source (including your UI changes)
COPY . .
# Compile the Javascript/CSS assets
RUN npm run build || echo "Build script not found or failed, continuing..."

# Stage 3: Final Production Image
# We layer your compiled web assets on top of the official image
FROM nextcloud:30-apache
COPY --from=composer_build /app/vendor /var/www/html/vendor
COPY --from=node_build /app /var/www/html/
RUN chown -R www-data:www-data /var/www/html
