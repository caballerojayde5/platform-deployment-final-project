#!/bin/sh
set -e

echo "Starting Symfony container..."
echo "PORT is: $PORT"

php bin/console cache:clear --env=prod
php bin/console doctrine:migrations:migrate --no-interaction

# Use sed instead of envsubst to avoid wiping nginx $variables
sed -i "s/\${PORT}/$PORT/g" /etc/nginx/conf.d/default.conf

echo "=== nginx config ==="
cat /etc/nginx/conf.d/default.conf

nginx -t

php-fpm -D
sleep 1

echo "Starting nginx..."
nginx -g "daemon off;"