# Development environment untuk Laravel dengan Composer + Node.js
FROM php:8.4-apache

WORKDIR /var/www/html

# Update package list
RUN apt-get update

# === ESSENTIAL CLI TOOLS (line-by-line untuk flexibility) ===
RUN apt-get install -y git
RUN apt-get install -y curl
RUN apt-get install -y wget
RUN apt-get install -y zip
RUN apt-get install -y unzip

# === EDITOR TOOLS (optional, uncomment jika butuh) ===
# RUN apt-get install -y vim
# RUN apt-get install -y nano

# === DATABASE TOOLS (line-by-line, mudah ganti DB) ===
RUN apt-get install -y sqlite3
RUN apt-get install -y libsqlite3-dev
# RUN apt-get install -y postgresql-client
# RUN apt-get install -y mysql-client

# === IMAGE PROCESSING LIBS (line-by-line, mudah customize) ===
RUN apt-get install -y libpng-dev
RUN apt-get install -y libjpeg-dev
RUN apt-get install -y libfreetype6-dev
# RUN apt-get install -y libwebp-dev
# RUN apt-get install -y imagemagick

# === PHP CORE LIBS (gabung, foundation stabil) ===
RUN apt-get install -y \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# === PHP EXTENSIONS (gabung, jarang berubah) ===
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install -j$(nproc) \
    pdo_sqlite \
    mbstring \
    dom \
    zip \
    pcntl \
    bcmath \
    fileinfo \
    exif \
    gd

# === APACHE MODULES (pisah untuk testing) ===
RUN a2enmod rewrite
RUN a2enmod headers
# RUN a2enmod expires
# RUN a2enmod ssl

# === COMPOSER (pisah, binary tool) ===
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# === NODE.JS (pisah, sering upgrade) ===
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
RUN apt-get install -y nodejs
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# === APACHE CONFIG ===
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf && \
    sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# EXPOSE 80

CMD ["apache2-foreground"]
