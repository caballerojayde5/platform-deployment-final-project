#!/bin/sh
set -e

echo "Starting Symfony container..."
echo "PORT is: $PORT"

php bin/console cache:clear --env=prod
php bin/console doctrine:migrations:migrate --no-interaction

# Substitute $PORT into nginx config
envsubst '${PORT}' < /etc/nginx/conf.d/default.conf > /tmp/nginx.conf
cp /tmp/nginx.conf /etc/nginx/conf.d/default.conf

# Show the resulting nginx config
echo "=== nginx config ==="
cat /etc/nginx/conf.d/default.conf

# Test nginx config
nginx -t

php-fpm -D
sleep 1
nginx -g "daemon off;"