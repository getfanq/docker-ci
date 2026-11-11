FROM ubuntu:24.04

ARG PHP_VERSION=8.5
ARG NODE_VERSION=24

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG DEBIAN_FRONTEND=noninteractive

ENV COMPOSER_ALLOW_SUPERUSER=1 \
    TZ=UTC \
    LANG=C.UTF-8

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg software-properties-common git unzip zip \
    && add-apt-repository -y ppa:ondrej/php \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        php${PHP_VERSION}-cli \
        php${PHP_VERSION}-mysql \
        php${PHP_VERSION}-pgsql \
        php${PHP_VERSION}-sqlite3 \
        php${PHP_VERSION}-xml \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-intl \
        php${PHP_VERSION}-zip \
        php${PHP_VERSION}-bcmath \
        php${PHP_VERSION}-gd \
        php${PHP_VERSION}-redis \
        php${PHP_VERSION}-apcu \
        php${PHP_VERSION}-amqp \
    && update-alternatives --set php /usr/bin/php${PHP_VERSION} \
    && printf 'memory_limit=512M\ndate.timezone=UTC\n' > /etc/php/${PHP_VERSION}/cli/conf.d/99-ci.ini \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && npm install -g pnpm \
    && npx --yes playwright install-deps \
    && npm cache clean --force \
    && rm -rf /var/lib/apt/lists/*

RUN php --version && composer --version && node --version && pnpm --version

WORKDIR /app
CMD ["/bin/bash"]
