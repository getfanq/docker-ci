# CI image

A single Docker image for PHP and JavaScript CI jobs, including the Linux
libraries needed to run Playwright browsers.

## What's included

| Component | Version | Purpose |
| --- | --- | --- |
| Ubuntu | 24.04 LTS | Base operating system |
| PHP CLI + CGI | 8.5 | Run PHP tests and Symfony's local server |
| Symfony CLI | Stable at build time | Serve the API during E2E tests |
| PostgreSQL client | Ubuntu package | Database readiness checks (`pg_isready`) |
| Composer | 2 | Install and manage PHP dependencies |
| Node.js | 24.x | Run JavaScript tooling and applications |
| npm | Bundled with Node.js | Install Node.js packages |
| pnpm | 12.16.1 | Install project dependencies and run scripts |
| Playwright system dependencies | 1.64.1 requirements | Linux libraries and fonts for Chromium, Firefox, and WebKit |
| Git, curl, zip, unzip | Ubuntu packages | Fetch source code, download files, and handle archives |
| Bash, CA certificates, GnuPG | Ubuntu packages | Shell commands, HTTPS, and package repository verification |

### PHP extensions

Alongside PHP's built-in modules, the image installs:

- **Databases:** MySQL/PDO MySQL, PostgreSQL/PDO PostgreSQL, SQLite/PDO SQLite.
- **Documents and networking:** XML, curl, and zip.
- **Strings and localization:** mbstring and intl.
- **Math and images:** bcmath and GD.
- **Caching and messaging:** Redis, APCu, and AMQP.

PHP CLI uses a **512 MB memory limit** and the **UTC timezone**.
Composer is allowed to run as root for CI jobs.

### Not included

- Playwright browser binaries or a project-level Playwright package.
- PHP-FPM or a production web server.
- Database servers or MySQL command-line clients.
- Your application's source code, Composer packages, or Node.js dependencies.

Install application dependencies in your CI job. Database extensions let PHP
connect to external services; they do not start databases inside this image.

## Use

```sh
docker pull ghcr.io/getfanq/ci:latest
docker run --rm -it -v "$PWD:/app" ghcr.io/getfanq/ci:latest
```

The working directory is `/app`. The image runs as root for CI usage.

Install your project's Playwright browsers before running tests:

```sh
pnpm install --frozen-lockfile
pnpm exec playwright install chromium
pnpm exec playwright test
```

System dependencies use the pinned `PLAYWRIGHT_VERSION` build argument. Keep it
aligned with the monorepo lockfile when upgrading Playwright. Browser binaries
still come from the project's Playwright package; do not run `--with-deps` in
image-backed CI jobs.

## Build locally

```sh
docker build -t ci .
docker run --rm ci bash -ec 'php -v && composer --version && node -v && pnpm -v'
```

Versions live in the root `Dockerfile`; there is no build matrix or config layer.
GitHub Actions builds and smoke-tests the single Linux amd64 image on pull
requests, and publishes `latest`, `azure-v1`, and `sha-<commit>` tags from main
and nightly. `azure-v1` identifies the Azure-capable toolchain but is mutable;
use a registry digest for reproducible pipeline runs.

## Azure rollout

1. Merge and publish this image before enabling the monorepo's container jobs.
2. Copy the pushed manifest digest from the workflow logs (or registry).
3. Set the monorepo's `ciImage` pipeline parameter/default to
   `ghcr.io/getfanq/ci@sha256:<digest>`. Its initial `azure-v1` default requires
   this updated image; the old `latest` image lacks CGI, Symfony and pg_isready.
4. Run API and E2E jobs with fresh and warm dependency caches. Include image
   initialization and cache transfer in duration comparisons.

The image deliberately runs as root and has no ENTRYPOINT, as required by the
Azure container-job setup. PostgreSQL and S3 run as separate service containers.

The separate [PostgreSQL backup image](namespaces/postgres-backup-s3/README.md)
is unchanged and uses its own build script and workflow.
