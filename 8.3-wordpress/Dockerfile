FROM wordpress:php8.3-apache

# Update package lists
RUN apt-get update

# Install PHP extensions and dependencies
RUN apt-get install -y libcurl4-openssl-dev
RUN docker-php-ext-install curl

# xml and dom: XML parsing and DOM manipulation
RUN apt-get install -y libxml2-dev
RUN docker-php-ext-install dom

# igbinary: PHP serializer replacement
RUN pecl install igbinary
RUN docker-php-ext-enable igbinary

# apcu: In-memory key-value store
RUN pecl install apcu
RUN docker-php-ext-enable apcu

# redis: PHP extension for Redis
RUN pecl install redis
RUN docker-php-ext-enable redis

# timezonedb: Timezone database for PHP
RUN pecl install timezonedb
RUN docker-php-ext-enable timezonedb

# shmop: Shared memory operations
RUN docker-php-ext-install shmop

# ssh2: Secure Shell connections
RUN apt-get install -y libssh2-1-dev
RUN pecl install ssh2-1.3.1
RUN docker-php-ext-enable ssh2

# sockets: BSD sockets interface
RUN docker-php-ext-install sockets

# Clean up to reduce image size
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Enable additional Apache modules
RUN a2enmod vhost_alias
RUN a2enmod headers
