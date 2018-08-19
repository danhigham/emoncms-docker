# Offical Docker PHP & Apache image https://hub.docker.com/_/php/
FROM php:7.0-apache

# Install deps
RUN apt-get update && apt-get install -y \
              libcurl4-gnutls-dev \
              libmcrypt-dev \
              libmosquitto-dev \
              git-core

# Enable PHP modules
RUN docker-php-ext-install -j$(nproc) mysqli curl json mcrypt gettext
RUN pecl install redis-3.1.6 \
  \ && docker-php-ext-enable redis
RUN pecl install Mosquitto-0.4.0 \
  \ && docker-php-ext-enable mosquitto

RUN a2enmod rewrite

# Add custom PHP config
COPY php.ini /usr/local/etc/php/

# NOT USED ANYMORE - GIT CLONE INSTEAD
# Copy in emoncms files, files can be mounted from local FS for dev see docker-compose
# ADD ./emoncms /var/www/html

COPY /tmp/build/put/emoncms-repo /var/www/html
COPY /tmp/build/put/emoncms-dashboard-repo /var/www/html/dashboard
COPY /tmp/build/put/emoncms-graph-repo /var/www/html/graph
COPY /tmp/build/put/emoncms-app-repo /var/www/html/app

COPY docker.settings.php /var/www/html/settings.php

# Create folders & set permissions for feed-engine data folders (mounted as docker volumes in docker-compose)
RUN mkdir /var/lib/phpfiwa
RUN mkdir /var/lib/phpfina
RUN mkdir /var/lib/phptimeseries
RUN chown www-data:root /var/lib/phpfiwa
RUN chown www-data:root /var/lib/phpfina
RUN chown www-data:root /var/lib/phptimeseries

# Create Emoncms logfile
RUN touch /var/log/emoncms.log
RUN chmod 666 /var/log/emoncms.log


# TODO
# Add Pecl :
# - dio
# - Swiftmailer
