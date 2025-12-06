# Development environment untuk Laravel dengan Composer + Node.js
FROM php:8.4-apache

WORKDIR /var/www/html

# === INSTALL ALL PACKAGES IN ONE LAYER (fastest for CI) ===
RUN apt-get update && apt-get install -y \
    # Essential CLI tools
    git \
    curl \
    wget \
    zip \
    unzip \
    # Database tools
    sqlite3 \
    libsqlite3-dev \
    default-mysql-client \
    postgresql-client \
    # Redis
    redis-server \
    # Image processing libs
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    # PHP core libs
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libpq-dev \
    libicu-dev \
    supervisor \
    # Node.js (from apt instead of nodesource for speed)
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    # Cleanup in same layer
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# === PHP EXTENSIONS (combined, rarely changes) ===
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install -j$(nproc) \
    pdo_sqlite \
    pdo_mysql \
    pdo_pgsql \
    mbstring \
    dom \
    zip \
    pcntl \
    bcmath \
    fileinfo \
    exif \
    gd \
    intl \
    opcache \
    sockets \
    && pecl install redis \
    && docker-php-ext-enable redis

# === APACHE MODULES (combined) ===
RUN a2enmod rewrite headers

# === COMPOSER (separate layer, changes less frequently) ===
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# === OPCACHE CONFIG (optimized for development) ===
RUN echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/opcache.ini && \
    echo "opcache.revalidate_freq=0" >> /usr/local/etc/php/conf.d/opcache.ini && \
    echo "opcache.validate_timestamps=1" >> /usr/local/etc/php/conf.d/opcache.ini

# === APACHE CONFIG ===
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf && \
    sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

EXPOSE 80

CMD ["apache2-foreground"]
