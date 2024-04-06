#!/bin/sh
cd /app/laravel
if [[ -d "vendor" ]]; then
  echo "vendor directory exists";
else
  composer install
  php artisan key:generate
  php artisan config:cache
fi;

php artisan serve --host=0.0.0.0 --port=$LARAVEL_PORT 
