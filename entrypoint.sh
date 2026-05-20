#!/bin/sh

echo "Starting Symfony container..."

# Clear Symfony cache
php bin/console cache:clear --env=prod

# Run migrations
php bin/console doctrine:migrations:migrate --no-interaction

# Start PHP-FPM
php-fpm -D

# Start Nginx
nginx -g "daemon off;"