# Apache - PHP Docker Image for WordPress

Production-oriented WordPress image: **`tediscript/apache-php:8.3-wordpress`**

- **PHP 8.3.36** on a digest-pinned `wordpress:php8.3-apache` base (includes the
  2026-10-21 out-of-band security release fixing CVE-2026-109618 / CVE-2026-109619)
- Pinned pecl extensions: igbinary 3.2.17RC1, apcu 5.1.28, redis 6.3.0,
  timezonedb 2026.6, ssh2 1.5.0 (+ curl, dom, imagick, mysqli from the base)
- **WP-CLI 2.12.0** (sha512-verified from the official release)
- Built-in Docker **HEALTHCHECK** (curl-based)

## Safe & fast by default

| Layer | Defaults |
|---|---|
| PHP limits | memory 256M, uploads 64M, max_execution_time 300, max_input_vars 3000 |
| OPcache | 256M memory, 20000 files, 60s revalidate, 32M interned strings |
| Filesystem | realpath cache 4096K / 600s |
| Logging | errors to stderr (`docker logs`), `display_errors=Off`, `expose_php=Off` |
| Sessions | `cookie_httponly=1`, `use_strict_mode=1` |
| Apache | gzip (mod_deflate, text types only), `ServerTokens Prod`, `ServerSignature Off`, `TraceEnable Off`, vhost_alias + headers modules |

## Tags & rollback

| Tag | Meaning |
|---|---|
| `8.3-wordpress` | Rolling — advances to each new build **only after the test suite passes** |
| `8.3-wordpress-YYYYMMDDHHMMSS` | Permanent per-build record (UTC build time) |
| `8.3-wordpress-rollback` | Convenience alias to the previous known-good build |

Rollback in 3 commands:

```bash
docker pull tediscript/apache-php:8.3-wordpress-rollback
docker tag  tediscript/apache-php:8.3-wordpress-rollback tediscript/apache-php:8.3-wordpress
docker push tediscript/apache-php:8.3-wordpress
```

## Change config without rebuilding

The `zz-*.ini` / `zz-*.conf` files in `8.3-wordpress/` are baked into the image
**and** bind-mounted by `docker-compose.yml`:

1. Edit the file (e.g. `zz-wordpress.ini`)
2. `docker compose restart php83`

**Warning:** mount individual files only. Bind-mounting a whole directory over
`/usr/local/etc/php/conf.d` hides the extension ini files (apcu, redis, ...) and
silently breaks extension loading.

## WP-CLI

Bundled in the image:

```bash
docker exec -it <container> wp core update
docker exec -it <container> wp plugin list
docker exec -it <container> wp db check
```

## Maintenance (for this repo)

- **`8.3-wordpress/test.sh`** — 42-check verification suite (versions, pins,
  ini values, Apache modules, live gzip, healthcheck). Run locally before
  pushing; CI runs it as a gate and **only pushes to Docker Hub if it passes**.
- **Renovate** (see `renovate.json`, explained in [`docs/renovate.md`](docs/renovate.md)) opens PRs when the upstream
  `wordpress:php8.3-apache` digest moves and when the laravel-dev base tags
  update (it also digest-pins those). Every PR runs the test suite — CI builds
  and tests on `pull_request` but never pushes to Docker Hub.
  When merging a base digest bump, also update `PHP_EXPECTED` in `test.sh`
  if the PHP patch version changed; the PR stays red until you do.
- The base digest is pinned in the Dockerfile `FROM` line — security updates
  arrive via Renovate PRs, by design.

## Deliberately not enabled by default

- **Object cache** (`WP_CACHE`) — apcu/redis extensions ship but WordPress needs
  a site-level `object-cache.php` drop-in. With a Redis server:
  `wp plugin install redis-cache --activate && wp redis enable`.
- **OPcache JIT** — revisit after burn-in.
- **mod_expires** browser caching — risks stale hand-coded (non-`?ver=`) assets.

## Repo layout

- `8.3-wordpress/` — this image
- `8.4-laravel-dev/`, `8.5-laravel-dev/` — Laravel dev images
- `archive/` — retired WordPress images (7.4, 8.2)

Reference: https://make.wordpress.org/hosting/handbook/server-environment/

## Github repo for this image: https://github.com/tediscript/apache-php

---

## Preventing WordPress Auto-Generation in Container

If you want to prevent the container from auto-generating a fresh WordPress installation, create the following empty files in your `/var/www/html` directory (either on your host if bind mounting, or inside the container):


### Using absolute path (inside container or absolute host path):
```
mkdir -p /var/www/html/wp-includes
touch /var/www/html/index.php /var/www/html/wp-includes/version.php /var/www/html/wp-config.php
```

### Using relative path (inside your html directory for bind mount):
```
cd html
mkdir -p wp-includes
touch index.php wp-includes/version.php wp-config.php
```

This will ensure the entrypoint script does not copy WordPress files or auto-generate a config file.
