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

# ---- PHP settings (zz- prefix loads last, overrides earlier defaults) ----
# Files live in the repo so they can be tweaked and bind-mounted in
# docker-compose.yml without rebuilding the image.
COPY zz-*.ini /usr/local/etc/php/conf.d/

# ---- WP-CLI, pinned to release v2.12.0 and sha512-verified ----
RUN set -eux; \
    curl -fsSLo /usr/local/bin/wp https://github.com/wp-cli/wp-cli/releases/download/v2.12.0/wp-cli-2.12.0.phar; \
    echo 'be928f6b8ca1e8dfb9d2f4b75a13aa4aee0896f8a9a0a1c45cd5d2c98605e6172e6d014dda2e27f88c98befc16c040cbb2bd1bfa121510ea5cdf5f6a30fe8832  /usr/local/bin/wp' | sha512sum -c -; \
    chmod +x /usr/local/bin/wp; \
    wp --allow-root --version | grep 'WP-CLI 2.12.0'

# Enable additional Apache modules
RUN a2enmod vhost_alias headers

# Apache: response compression (text types only) + version-info hygiene
COPY zz-deflate.conf zz-security.conf /etc/apache2/conf-available/
RUN a2enmod deflate && a2enconf zz-deflate zz-security

# Container reports healthy when Apache answers on localhost
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -fsS http://localhost/ || exit 1

# PR gate verification placeholder comment
