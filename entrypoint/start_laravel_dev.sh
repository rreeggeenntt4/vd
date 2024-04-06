#!/bin/sh
cd /app/laravel
if [[ -d "vendor" ]]; then
  echo "vendor directory exists";
  #composer update;
  #composer dump-autoload;

else
  composer install
  composer update;
  composer dump-autoload;
  php artisan key:generate
  php artisan config:cache
fi;

php artisan serve --host=0.0.0.0 --port=$LARAVEL_PORT 
