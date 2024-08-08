# Use the official PHP 7.4 image with Apache
FROM php:8.2-apache

# Update package lists
RUN apt-get update


# Using this reference: https://make.wordpress.org/hosting/handbook/server-environment/


# json (bundled in >=8.0.0) – Used for communications with other servers and processing data in JSON format.
# Install json extension
# RUN docker-php-ext-install json


# One of either mysqli (bundled in >=5.0.0), or mysqlnd – Connects to MySQL for database interactions.
# Install the necessary PHP extensions
RUN docker-php-ext-install mysqli
# Install pdo extension
RUN docker-php-ext-install pdo
# Install pdo_mysql extension
RUN docker-php-ext-install pdo_mysql


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


# exif (requires php-mbstring) – Works with metadata stored in images.
# Install exif extension
RUN docker-php-ext-install exif


# fileinfo (bundled in PHP) – Used to detect mimetype of file uploads.
# Install fileinfo extension
# RUN docker-php-ext-install fileinfo


# hash (bundled in PHP >=5.1.2) – Used for hashing, including passwords and update packages.
# Install hash extension
# RUN docker-php-ext-install hash


# igbinary – Increases performance as a drop in replacement for the standard PHP serializer.
# Install PECL extensions
RUN pecl install igbinary
# Enable PECL extensions
RUN docker-php-ext-enable igbinary


# imagick (requires ImageMagick >= 6.2.4) – Provides better image quality for media uploads. See WP_Image_Editor for details. Smarter image resizing (for smaller images) and PDF thumbnail support, when Ghost Script is also available.
# Install libmagickwand-dev
RUN apt-get install -y libmagickwand-dev
# Ghost Script (recommended Ghost Script >= 10.0)- Enables Imagick/ImageMagick to generate PDF thumbnails for the media library. See Enhanced PDF Support in WordPress 4.7 for details.
# Install ghostscript
RUN apt-get install -y ghostscript
# Install PECL extensions
RUN pecl install imagick
# Enable PECL extensions
RUN docker-php-ext-enable imagick


# intl (PHP >= 7.4.0 requires ICU >= 50.1) – Enable to perform locale-aware operations including but not limited to formatting, transliteration, encoding conversion, calendar operations, conformant collation, locating text boundaries and working with locale identifiers, timezones and graphemes.
# Install libicu for intl extension
RUN apt-get install -y libicu-dev
# Install intl extensions
RUN docker-php-ext-install intl


# mbstring – Used to properly handle UTF8 text.
# Install libonig-dev
RUN apt-get install -y libonig-dev
# Install mbstring extension
RUN docker-php-ext-install mbstring


# openssl (PHP 7.1-8.0 requires OpenSSL >= 1.0.1 / < 3.0; PHP >= 8.1 requires OpenSSL >= 1.0.2 / < 4.0) – SSL-based connections to other hosts.


# pcre (bundled in PHP >= 7.0 recommended PCRE 8.10) – Increases performance of pattern matching in code searches.


# xml (bundled) (requires libxml) – Used for XML parsing, such as from a third-party site.


# zip (requires libzip >= 0.11; recommended libzip >= 1.6) – Used for decompressing Plugins, Themes, and WordPress update packages.
# Install libzip-dev
RUN apt-get install -y libzip-dev
# Install zip extension
RUN docker-php-ext-install zip


# apcu – In-memory key-value store for PHP (former APC stripped of opcode caching).
# Install PECL extensions
RUN pecl install apcu 
# Enable PECL extensions
RUN docker-php-ext-enable apcu


# opcache – PHP can be configured to preload scripts into the opcache when the engine starts.
# Install OPcache extension
RUN docker-php-ext-install opcache


# TODO: memcached (requires libmemcached >= 1.0.0) – memcached is a high-performance, distributed memory object caching system, generic in nature, but intended for use in speeding up dynamic web applications by alleviating database load.


# redis – PHP extension for interfacing with Redis.
# Install PECL extensions
RUN pecl install redis
# Enable PECL extensions
RUN docker-php-ext-enable redis


# timezonedb – Timezone Database to be used with PHP’s date and time functions
# Install the timezonedb extension
RUN pecl install timezonedb
# Enable the timezonedb extension
RUN docker-php-ext-enable timezonedb


# bc – For arbitrary precision mathematics, which supports numbers of any size and precision up to 2147483647 decimal digits.
# Install the bc package
RUN docker-php-ext-install bcmath


# filter (bundled) – Used for securely filtering user input.


# image (requires libgd >= 2.1.0; requires zlib >= 1.2.0.4; optional freetype2) – If Imagick isn’t installed, the GD Graphics Library is used as a functionally limited fallback for image manipulation.
# Install required dependencies for the GD extension
RUN apt-get install -y libfreetype6-dev
RUN apt-get install -y libjpeg62-turbo-dev
RUN apt-get install -y libpng-dev
RUN apt-get install -y libwebp-dev
RUN apt-get install -y libxpm-dev
RUN apt-get install -y libavif-dev
# Configure GD extension
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --with-xpm
# Install GD extension
RUN docker-php-ext-install -j$(nproc) gd



# iconv (bundled) (requires libiconv/POSIX) – Used to convert between character sets.


# shmop – Shmop is an easy to use set of functions that allows PHP to read, write, create and delete Unix shared memory segments.
# Install shmop extension
RUN docker-php-ext-install shmop


# simplexml (bundled) (requires libxml) – Used for XML parsing.


# sodium (bundled) – (bundled in PHP >=7.2.0; requires libsodium >= 1.0.8) – Validates Signatures and provides securely random bytes.


# xmlreader (bundled) (requires libxml) – Used for XML parsing.


# zlib (bundled) (requires zlib >= 1.2.0.4) – Gzip compression and decompression.


# ssh2 (requires OpenSSL and libssh >= 1.2; recommended libssh >= 1.2.9) – Provide access to resources (shell, remote exec, tunneling, file transfer) on a remote machine using a secure cryptographic transport.
# libssh2 (requires libssh2 >= 1.2) – Used for Secure Shell (SSH) connections.
RUN apt-get install -y libssh2-1-dev
# Install ssh2 extension
RUN pecl install ssh2-1.3.1
# Enable ssh2 extension
RUN docker-php-ext-enable ssh2


# ftp (bundled) – Implement client access to files servers speaking the File Transfer Protocol (FTP).


# sockets – Implements a low-level interface to the socket communication functions based on the popular BSD sockets.
# Install sockets extension
RUN docker-php-ext-install sockets


# curl (bundled) (recommended >= 8.4)




# Clean up to reduce image size
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Set recommended PHP settings
# COPY ./custom.ini /usr/local/etc/php/conf.d/custom.ini

# Copy custom virtual host configuration
# COPY ./000-default.conf /etc/apache2/sites-available/000-default.conf


# Set the working directory
WORKDIR /var/www/html

# Expose port 80
EXPOSE 80

# Start Apache server
CMD ["apache2-foreground"]