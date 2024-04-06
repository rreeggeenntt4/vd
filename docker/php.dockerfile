FROM php:8-fpm-alpine
WORKDIR /app
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
RUN apk add unzip libpq-dev && docker-php-ext-install pdo pdo_pgsql pgsql
