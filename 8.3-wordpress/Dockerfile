# Locked to wordpress:php8.3-apache (2026-10-28 rebuild) shipping PHP 8.3.36,
# the out-of-band security release fixing the 2026-10-21 critical RCEs
# CVE-2026-109618 and CVE-2026-109619.
FROM wordpress:php8.3-apache@sha256:848b03bb7b4b160e3a670454e8e928e309c9aaeb1c2584e917f42ab5197662e2

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
