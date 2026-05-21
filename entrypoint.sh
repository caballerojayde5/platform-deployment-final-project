#!/bin/sh
set -e

echo "Starting Symfony container..."

# Clear Symfony cache
php bin/console cache:clear --env=prod

# Run migrations
php bin/console doctrine:migrations:migrate --no-interaction

# Substitute $PORT into nginx config
envsubst '${PORT}' < /etc/nginx/conf.d/default.conf > /tmp/nginx.conf
cp /tmp/nginx.conf /etc/nginx/conf.d/default.conf

# Start PHP-FPM in background (daemon)
php-fpm -D

# Give php-fpm a moment to start
sleep 1

# Start Nginx in foreground (keeps container alive)
nginx -g "daemon off;"