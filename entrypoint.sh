#!/bin/sh
set -e

echo "Starting Symfony container..."
echo "PORT is: $PORT"

php bin/console cache:clear --env=prod

echo "DATABASE_URL is: $DATABASE_URL"

# Fix permissions AFTER cache:clear creates the directories
chown -R www-data:www-data /var/www/var
chmod -R 775 /var/www/var

# Wait for MySQL to be read
echo "Waiting for database connection..."
until php bin/console doctrine:query:sql "SELECT 1" > /dev/null 2>&1; do
  echo "Database not ready, retrying in 3 seconds..."
  sleep 3
done
echo "Database is ready!"

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