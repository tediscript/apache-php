# Use the official WordPress PHP 8.3 image with Apache
FROM wordpress:php8.3-apache

# Update package lists
RUN apt-get update


# Using this reference: https://make.wordpress.org/hosting/handbook/server-environment/
# Note: wordpress:php8.3-apache already includes: bcmath, exif, gd, intl, mysqli, zip, imagick, opcache


# curl (PHP >= 7.3 requires libcurl >= 7.15.5; PHP >= 8.0 requires libcurl >= 7.29.0) – Performs remote request operations.
# Install libcurl4-openssl-dev
RUN apt-get install -y libcurl4-openssl-dev
# Install curl extension
RUN docker-php-ext-install curl


# dom (requires libxml) – Used to validate Text Widget content and to automatically configure IIS7+.
# Install libxml for dom and xml extensions
RUN apt-get install -y libxml2-dev
# Install dom extension
RUN docker-php-ext-install dom


# igbinary – Increases performance as a drop in replacement for the standard PHP serializer.
# Install PECL extensions
RUN pecl install igbinary
# Enable PECL extensions
RUN docker-php-ext-enable igbinary


# apcu – In-memory key-value store for PHP (former APC stripped of opcode caching).
# Install PECL extensions
RUN pecl install apcu 
# Enable PECL extensions
RUN docker-php-ext-enable apcu


# memcached (requires libmemcached >= 1.0.0) – memcached is a high-performance, distributed memory object caching system, generic in nature, but intended for use in speeding up dynamic web applications by alleviating database load.
# TODO: Add memcached support later - currently having configuration issues
# RUN apt-get install -y libmemcached-dev zlib1g-dev
# RUN pecl install memcached
# RUN docker-php-ext-enable memcached


# redis – PHP extension for interfacing with Redis.
# Install PECL extensions
RUN pecl install redis
# Enable PECL extensions
RUN docker-php-ext-enable redis


# timezonedb – Timezone Database to be used with PHP's date and time functions
# Install the timezonedb extension
RUN pecl install timezonedb
# Enable the timezonedb extension
RUN docker-php-ext-enable timezonedb


# shmop – Shmop is an easy to use set of functions that allows PHP to read, write, create and delete Unix shared memory segments.
# Install shmop extension
RUN docker-php-ext-install shmop


# ssh2 (requires OpenSSL and libssh >= 1.2; recommended libssh >= 1.2.9) – Provide access to resources (shell, remote exec, tunneling, file transfer) on a remote machine using a secure cryptographic transport.
# libssh2 (requires libssh2 >= 1.2) – Used for Secure Shell (SSH) connections.
RUN apt-get install -y libssh2-1-dev
# Install ssh2 extension
RUN pecl install ssh2-1.3.1
# Enable ssh2 extension
RUN docker-php-ext-enable ssh2


# sockets – Implements a low-level interface to the socket communication functions based on the popular BSD sockets.
# Install sockets extension
RUN docker-php-ext-install sockets


# Fix CVE-2024-5171
# TODO: Update libaom3 when fixed version becomes available in stable repository
# RUN echo "deb http://deb.debian.org/debian sid main" > /etc/apt/sources.list.d/sid.list
# RUN apt-get update
# RUN apt-get install -y --no-install-recommends libaom3=3.9.1-1


# Clean up to reduce image size
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Enable additional Apache modules (rewrite, expires, remoteip already enabled in WordPress base)
RUN a2enmod vhost_alias
RUN a2enmod headers


# Working directory and port are already set in WordPress base image
# WORKDIR /var/www/html
# EXPOSE 80

# Entry point and CMD are already set in WordPress base image
# ENTRYPOINT ["docker-entrypoint.sh"]
# CMD ["apache2-foreground"]
