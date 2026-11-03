#!/usr/bin/env bash
# Verification suite for the 8.3-wordpress image.
#
# Usage:
#   ./test.sh                      build apache-php:8.3-wordpress-test, then test
#   ./test.sh <image>              test a specific local image
#   ./test.sh <image> --no-build   test without building (used by CI)
#
# Exit codes: 0 = all checks passed, 1 = test failures, 2 = setup error
#
# NOTE: PHP_EXPECTED is tied to the base image digest pinned in the Dockerfile.
# When bumping the digest (e.g. via the drift-check PR), update PHP_EXPECTED
# here in the same commit -- CI will keep the PR red until you do.

set -uo pipefail
cd "$(dirname "$0")"

# ---------- config ----------
IMAGE="${1:-apache-php:8.3-wordpress-test}"
NO_BUILD="${2:-}"
CONTAINER="wp83-test-$$"
PORT="${TEST_PORT:-18080}"
PHP_EXPECTED="8.3.36"
WPCLI_EXPECTED="2.12.0"
STARTUP_TIMEOUT=30    # seconds waiting for container to stay up
WEB_TIMEOUT=60        # seconds waiting for HTTP 200
HEALTH_TIMEOUT=90     # seconds waiting for healthy state

# ---------- output ----------
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  GREEN=$'\033[32m'; RED=$'\033[31m'; BOLD=$'\033[1m'; RST=$'\033[0m'
else
  GREEN=''; RED=''; BOLD=''; RST=''
fi
PASS_COUNT=0
FAIL_COUNT=0
pass() { PASS_COUNT=$((PASS_COUNT+1)); printf '  %sPASS%s  %s\n' "$GREEN" "$RST" "$*"; }
fail() { FAIL_COUNT=$((FAIL_COUNT+1)); printf '  %sFAIL%s  %s\n' "$RED" "$RST" "$*" >&2; }
step() { printf '%s==> %s%s\n' "$BOLD" "$*" "$RST"; }

# ---------- preflight ----------
for bin in docker curl awk grep sed sleep; do
  command -v "$bin" >/dev/null 2>&1 || { echo "setup error: missing dependency: $bin" >&2; exit 2; }
done
docker info >/dev/null 2>&1 || { echo "setup error: docker daemon not reachable" >&2; exit 2; }

# pick a free port if the default is taken
port_busy() { (exec 3<>"/dev/tcp/127.0.0.1/$1") 2>/dev/null && { exec 3>&- 3<&-; return 0; } || return 1; }
if port_busy "$PORT"; then
  step "Port $PORT busy, picking a free one"
  for _ in 1 2 3 4 5 6 7 8 9 10; do
    PORT=$(( (RANDOM % 3000) + 20000 ))
    port_busy "$PORT" || break
  done
fi

# ---------- lifecycle ----------
cleanup() { docker rm -f "$CONTAINER" >/dev/null 2>&1 || true; }
trap cleanup EXIT INT TERM

dump_logs() {
  echo "---- container logs (last 30 lines) ----" >&2
  docker logs --tail 30 "$CONTAINER" >&2 2>&1 || true
  echo "----------------------------------------" >&2
}

# ---------- build ----------
if [ "$NO_BUILD" != "--no-build" ]; then
  step "Building $IMAGE"
  if ! docker build --platform linux/amd64 -t "$IMAGE" . >"$PWD/.test-build.log" 2>&1; then
    echo "setup error: build failed -- last 30 lines:" >&2
    tail -30 "$PWD/.test-build.log" >&2
    rm -f "$PWD/.test-build.log"
    exit 2
  fi
  rm -f "$PWD/.test-build.log"
fi

# ---------- start ----------
step "Starting container ($IMAGE on port $PORT)"
docker run --rm -d --platform linux/amd64 --name "$CONTAINER" -p "$PORT":80 "$IMAGE" >/dev/null \
  || { echo "setup error: docker run failed" >&2; exit 2; }

# fail fast if the container crash-loops (no restart policy: dead = dead)
OK_START=0
for _ in 1 2 3 4 5; do
  STATE=$(docker inspect "$CONTAINER" --format '{{.State.Status}}' 2>/dev/null || echo gone)
  case "$STATE" in
    running) OK_START=1; break ;;
    exited|dead|gone)
      echo "setup error: container state '$STATE' (crash loop? bad entrypoint?)" >&2
      dump_logs
      exit 2 ;;
    *) sleep 2 ;;
  esac
done
[ "$OK_START" = "1" ] || { echo "setup error: container never reached running state" >&2; dump_logs; exit 2; }
sleep 2  # give the entrypoint a beat

# ---------- 1. PHP version (base digest lock) ----------
step "1/9 PHP version (base digest lock)"
GOT=$(docker exec "$CONTAINER" php -r 'echo PHP_VERSION;' 2>/dev/null)
[ "$GOT" = "$PHP_EXPECTED" ] && pass "PHP $GOT" || fail "PHP version: got '$GOT', want '$PHP_EXPECTED'"

# ---------- 2. PHP extensions ----------
step "2/9 PHP extensions"
EXTS=$(docker exec "$CONTAINER" php -m 2>/dev/null)
for e in apcu curl dom igbinary redis shmop sockets ssh2 timezonedb; do
  echo "$EXTS" | grep -qx "$e" && pass "extension $e" || fail "extension $e missing"
done

# ---------- 3. pecl version pins ----------
step "3/9 pecl version pins"
PECL=$(docker exec "$CONTAINER" pecl list 2>/dev/null)
while read -r name ver; do
  GOT=$(echo "$PECL" | awk -v p="$name" '$1==p{print $2}')
  [ "$GOT" = "$ver" ] && pass "pecl $name $ver" || fail "pecl $name: got '$GOT', want '$ver'"
done <<'EOF'
ssh2 1.5.0
apcu 5.1.28
redis 6.3.0
igbinary 3.2.17RC1
timezonedb 2026.6
EOF

# ---------- 4. ini settings ----------
step "4/9 ini settings"
INI=$(docker exec "$CONTAINER" php -i 2>/dev/null)
check_ini() {
  local key esc got
  key="$1"
  esc=$(printf '%s' "$key" | sed 's/\./\\./g')
  got=$(echo "$INI" | grep -E "^${esc} =>" | head -1 | awk '{print $3}')
  [ "$got" = "$2" ] && pass "$key = $2" || fail "$key: got '$got', want '$2'"
}
check_ini memory_limit 256M
check_ini upload_max_filesize 64M
check_ini post_max_size 64M
check_ini max_input_vars 3000
check_ini expose_php Off
check_ini display_errors Off
check_ini log_errors On
check_ini error_log /dev/stderr
check_ini opcache.memory_consumption 256
check_ini opcache.max_accelerated_files 20000
check_ini opcache.validate_timestamps On
check_ini opcache.revalidate_freq 60
# max_execution_time is 0 on CLI by design; verify the shipped ini file instead
CONF=$(docker exec "$CONTAINER" grep -h . /usr/local/etc/php/conf.d/zz-wordpress.ini 2>/dev/null)
echo "$CONF" | grep -q '^max_execution_time=300' \
  && pass "max_execution_time=300 (zz-wordpress.ini)" \
  || fail "max_execution_time=300 missing from zz-wordpress.ini"

# ---------- 5. WP-CLI ----------
step "5/9 WP-CLI"
GOT=$(docker exec "$CONTAINER" wp --allow-root --version 2>/dev/null | awk '{print $2}')
[ "$GOT" = "$WPCLI_EXPECTED" ] && pass "WP-CLI $GOT" || fail "WP-CLI: got '$GOT', want '$WPCLI_EXPECTED'"

# ---------- 6. Apache modules ----------
step "6/9 Apache modules"
MODS=$(docker exec "$CONTAINER" apache2ctl -M 2>/dev/null)
for m in vhost_alias_module headers_module; do
  echo "$MODS" | grep -q "$m" && pass "$m" || fail "$m not enabled"
done

# ---------- 7. Web serving ----------
# A fresh (uninstalled) WordPress 302-redirects / to the setup page, which is
# correct behavior -- follow redirects and require a final 2xx (PHP executed).
step "7/9 Web serving"
WEB_OK=0
for _ in $(seq 1 "$WEB_TIMEOUT"); do
  CODE=$(curl -sL -o /dev/null -m 10 -w "%{http_code}" "http://localhost:$PORT/" 2>/dev/null || echo 000)
  case "$CODE" in 2*) WEB_OK=1; break ;; esac
  sleep 1
done
[ "$WEB_OK" = "1" ] && pass "HTTP $CODE after redirects (PHP executing)" || { fail "no 2xx within ${WEB_TIMEOUT}s (last: $CODE)"; dump_logs; }

# ---------- 8. Healthcheck ----------
step "8/9 Healthcheck"
HEALTHY=0
for _ in $(seq 1 "$HEALTH_TIMEOUT"); do
  ST=$(docker inspect "$CONTAINER" --format '{{.State.Health.Status}}' 2>/dev/null || echo "?")
  if [ "$ST" = "healthy" ]; then HEALTHY=1; break; fi
  [ "$ST" = "unhealthy" ] && break   # no point waiting once marked unhealthy
  sleep 1
done
[ "$HEALTHY" = "1" ] && pass "container healthy" || fail "health status: $ST"

# ---------- 9. No dev headers ----------
step "9/9 No dev headers in final image"
DEVS=$(docker exec "$CONTAINER" dpkg -l 2>/dev/null | grep -cE "libcurl4-openssl-dev|libxml2-dev|libssh2-1-dev" || true)
[ "$DEVS" = "0" ] && pass "dev packages purged" || fail "dev packages present: $DEVS"

# ---------- summary ----------
echo
printf '%s%d passed, %d failed%s\n' "$BOLD" "$PASS_COUNT" "$FAIL_COUNT" "$RST"
if [ "$FAIL_COUNT" = "0" ]; then
  echo "ALL CHECKS PASSED"
  exit 0
else
  echo "SOME CHECKS FAILED" >&2
  exit 1
fi
