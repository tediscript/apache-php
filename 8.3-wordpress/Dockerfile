# Locked to wordpress:php8.3-apache (2026-10-28 rebuild) shipping PHP 8.3.36,
# the out-of-band security release fixing the 2026-10-21 critical RCEs
# CVE-2026-109618 and CVE-2026-109619.
FROM wordpress:php8.3-apache@sha256:848b03bb7b4b160e3a670454e8e928e309c9aaeb1c2584e917f42ab5197662e2

# Note: the base image already ships the curl and dom PHP extensions,
# so they are not rebuilt here.

# Single layer: install only the headers needed for compilation, build all
# pecl extensions (versions pinned for reproducible builds), enable them,
# then purge the -dev packages so headers do not ship in the final image.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends libssh2-1-dev; \
    pecl install igbinary-3.2.17RC1 apcu-5.1.28 redis-6.3.0 timezonedb-2026.6 ssh2-1.5.0; \
    docker-php-ext-enable igbinary apcu redis timezonedb ssh2; \
    docker-php-ext-install shmop sockets; \
    apt-get purge -y --auto-remove libssh2-1-dev; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Enable additional Apache modules
RUN a2enmod vhost_alias headers
