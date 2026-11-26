
FROM php:8.4-fpm-bookworm

# System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    unzip \
    zip \
    libicu-dev \
    libzip-dev \
    libpq-dev \
    libonig-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    && rm -rf /var/lib/apt/lists/*

# PHP extensions
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" \
        bcmath \
        exif \
        gd \
        intl \
        mbstring \
        opcache \
        pcntl \
        pdo_pgsql \
        zip

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# PHP configuration
COPY php.ini /usr/local/etc/php/conf.d/99-app.ini

WORKDIR /var/www/html

EXPOSE 9000

CMD ["php-fpm"]
