# How Renovate works in this repo

A practical guide. Renovate is an open-source bot (by Mend) that scans the repo
on a schedule, detects dependency references, and opens pull requests when newer
versions exist. This repo uses it so the pinned base images stay patched
without anyone watching Docker Hub.

## 1. How it is wired here

Everything Renovate does in this repo is controlled by one file: `renovate.json`
in the repo root. Field by field:

```jsonc
{
  "extends": ["config:recommended"],     // sane baseline preset from Renovate docs
  "schedule": ["before 5am on Monday"],  // bot only checks for updates weekly (UTC)
  "labels": ["dependencies"],            // every PR it opens gets this label
  "automerge": false,                    // NOTHING merges on its own -- human + CI only

  "packageRules": [
    {
      // The laravel-dev images use floating tags (php:8.4-apache, php:8.5-apache).
      // First run: pin them to digests (like the 8.3-wordpress base already is).
      // After that: PR whenever the digest moves.
      "matchFileNames": ["8.4-laravel-dev/**", "8.5-laravel-dev/**"],
      "matchCategories": ["docker"],
      "pinDigests": true
    },
    {
      // Base digest bumps for 8.3-wordpress may carry a new PHP patch version.
      // The test gate hard-asserts the version -- this label is the reminder.
      "matchFileNames": ["8.3-wordpress/**"],
      "matchUpdateTypes": ["digest", "pin"],
      "addLabels": ["requires-php-expected-bump-check"]
    }
  ]
}
```

## 2. What Renovate sees in this repo

| File | Renovate "manager" | Behavior |
|---|---|---|
| `8.3-wordpress/Dockerfile` (`FROM wordpress:php8.3-apache@sha256:...`) | dockerfile | Opens a PR when upstream rebuilds the tag (security/base-OS updates). The `@sha256:` pin is what makes this precise -- we always know exactly what we run. |
| `8.4-laravel-dev/Dockerfile`, `8.5-laravel-dev/Dockerfile` (`FROM php:8.4-apache`) | dockerfile | First: a "pin" PR adds `@sha256:...`. Then: digest PRs like above. |
| `.github/workflows/*.yml` (`actions/checkout@v4`, `docker/*-action@v6`) | github-actions | PR when new major versions of the actions release. |
| `docker-compose.yml` | -- | Nothing (build-only, no images referenced). |

What Renovate deliberately does NOT touch here:

- **pecl extension pins** (`igbinary-3.2.17RC1`, `ssh2-1.5.0`, ...) -- Renovate
  has no PECL registry support. Manual.
- **WP-CLI phar URL + sha512** -- Renovate could see the version in the URL, but
  cannot recompute the checksum, so its PR would fail verification. Manual.
- **`PHP_EXPECTED` in `test.sh`** -- always human. See section 4.

## 3. Lifecycle: what happens after you enable the app

1. You enable the Renovate app once: https://github.com/apps/renovate
   (Install -> select `tediscript/apache-php`).
2. Because `renovate.json` already exists, Renovate skips the usual onboarding
   PR and starts working within ~1-2 hours.
3. It opens a **Dependency Dashboard** issue (pinned in the issue tracker).
   This is a living table of every update it found: pending PRs, awaiting-schedule,
   blocked, etc. You can also command it there (see section 5).
4. Every Monday before 05:00 UTC it re-checks everything. New upstream digest ->
   new PR. No change -> silence.

## 4. Anatomy of a digest-bump PR (the important one)

Upstream rebuilds `wordpress:php8.3-apache` (say, PHP 8.3.36 -> 8.3.37 with a
security fix). Within a week:

1. Renovate opens a PR: `Update wordpress:php8.3-apache digest to sha256:abcd...`
   - labeled `dependencies` + `requires-php-expected-bump-check`
2. Our CI runs on the PR automatically (`pull_request` trigger): it builds the
   image and runs the 42-check suite. It **never pushes to Docker Hub from a PR**.
3. If the rebuild only patched base-OS packages: tests pass, PR is green.
   Review -> merge -> the push build advances the rolling tag + stamps a date tag.
4. If the PHP patch version changed: check 1 (`PHP version (base digest lock)`)
   fails -- PR is red until you edit `PHP_EXPECTED` in `8.3-wordpress/test.sh`
   to the new version. That red is *intentional*: a new PHP version reaching
   production should be a conscious human decision, not a silent bot action.

This is why the drift workflow Renovate replaced was deleted: two bots watching
the same digest would open duplicate PRs.

## 5. Day-to-day interaction

On the Dependency Dashboard issue (or in any Renovate PR), comment:

- `@renovate rebase` -- recreate a PR (e.g. after CI fixed itself)
- `@renovate recreate` -- discard and rebuild the PR from scratch
- `@renovate check this PR again` / dashboard checkbox commands like
  "check now" -- trigger a fresh scan out of schedule
- `@renovate ignore this dependency` -- stop proposing one specific update

Closing a Renovate PR tells it "not now" -- it will retry on the next schedule
run (default behavior) unless you set `"dependencyDashboardApproval": true`
in `renovate.json` to require explicit approval first.

## 6. Tuning knobs you might want later

```jsonc
"timezone": "Asia/Jakarta",            // schedule times in local time
"schedule": ["before 5am every weekday"],  // more frequent checks
"rangeStrategy": "bump",               // how version ranges are updated
"vulnerabilityAlerts": true,           // prioritize security updates
"automerge": true,                     // NOT recommended here: the PHP gate
                                        // must stay a human decision
"packageRules": [{ "matchUpdateTypes": ["patch"], "automerge": true }]
                                        // e.g. auto-merge only action patches
```

Full reference: https://docs.renovatebot.com/configuration-options/

## 7. Pausing or removing it

- Pause: add `"enabled": false` to `renovate.json`
- Stop entirely: uninstall the app from your GitHub settings
- The repo keeps working without Renovate -- you just lose automated update PRs
  (and should then manually watch the base image digests)
