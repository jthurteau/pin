##
# PHP8 FPM Dockerfile # https://hub.docker.com/_/php
# for ncsulibraries - jthurtea
# development container that mounts the repo

FROM php:8.2-fpm-alpine3.18 as builder

ARG PRIMARY_APPLICATION
ENV PRIMARY_APPLICATION=${PRIMARY_APPLICATION}
##
# deploy option 2
VOLUME ["/opt/application/${PRIMARY_APPLICATION}"]
VOLUME ["/opt/project"]
VOLUME ["/opt/appliction/vendor"]
COPY shell/deploy /opt/deploy
RUN mkdir /var/www/application \
  && /opt/deploy/lib.http-apps.sh $PRIMARY_APPLICATION public \
  ##
  # don't add composer via apk since php[-fpm] isn't managed by apk
  # && apk add composer \
  && /opt/deploy/composer.sh ~ \
  # look into using install-php-extensions @composer instead
  && apk add git \
  # if you need any pecl extensions
  && apk add pcre-dev ${PHPIZE_DEPS} \
  ##
  # sometimes add php-module dependencies via apk
  && apk add openldap-dev \
  && apk add yaml-dev \
  
  # https://github.com/mlocati/docker-php-extension-installer
    ##
    # we don't typically need to configure the plugins
    # && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ 
    ##
    # plugins we commonly need to add
    && docker-php-ext-install ldap \
    # && docker-php-ext-install oci8
    # possible packages : bcmath bz2 calendar ctype curl dba dom enchant exif 
    # ffi fileinfo filter ftp gd gettext gmp hash iconv imap intl json ldap mbstring 
    # mysqli oci8 odbc opcache pcntl pdo pdo_dblib pdo_firebird pdo_mysql pdo_oci 
    # pdo_odbc pdo_pgsql pdo_sqlite pgsql phar posix pspell readline reflection session 
    # shmop simplexml snmp soap sockets sodium spl standard sysvmsg sysvsem sysvshm tidy 
    # tokenizer xml xmlreader xmlwriter xsl zend_test zip
    && pecl install yaml \
	  && docker-php-ext-enable yaml
# Docker no likey cloning into /opt/application/vendor in the same RUN that created it...
# RUN git clone --branch prod https://github.com/dependency.git /opt/application/vendor/dependency
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini" \
  && rm /usr/local/etc/php-fpm.d/docker.conf
COPY php-fpm/debug.conf /usr/local/etc/php-fpm.d/docker-local.conf

WORKDIR /var/www/html

# CMD []
# ENTRYPOINT []

# Flag the PHP-FPM as Exposed :
EXPOSE 9000