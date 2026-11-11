# CI image

A single Docker image for PHP and JavaScript CI jobs, including the Linux
libraries needed to run Playwright browsers.

## What's included

| Component | Version | Purpose |
| --- | --- | --- |
| Ubuntu | 24.04 LTS | Base operating system |
| PHP CLI | 8.5 | Run PHP scripts, tests, and console commands |
| Composer | 2 | Install and manage PHP dependencies |
| Node.js | 24.x | Run JavaScript tooling and applications |
| npm | Bundled with Node.js | Install Node.js packages |
| pnpm | Latest at build time | Install project dependencies and run scripts |
| Playwright system dependencies | Latest Playwright requirements at build time | Linux libraries and fonts for Chromium, Firefox, and WebKit |
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
- PHP-FPM, a web server, or Symfony CLI.
- Database servers or MySQL/PostgreSQL command-line clients.
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
pnpm exec playwright install
pnpm exec playwright test
```

System dependencies are installed using the latest Playwright release at image
build time. The Playwright package and browser versions come from your project.

## Build locally

```sh
docker build -t ci .
docker run --rm ci bash -ec 'php -v && composer --version && node -v && pnpm -v'
```

Versions live in the root `Dockerfile`; there is no build matrix or config layer.
GitHub Actions builds and smoke-tests the single Linux amd64 image on pull
requests, and publishes `ghcr.io/getfanq/ci:latest` from main and nightly.

The separate [PostgreSQL backup image](namespaces/postgres-backup-s3/README.md)
is unchanged and uses its own build script and workflow.
