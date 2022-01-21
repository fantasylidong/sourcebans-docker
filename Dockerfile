FROM php:7.4-apache

ENV SOURCEBANS_VERSION=1.6.4 \
    REMOVE_SETUP_DIRS=false

RUN apt-get update && \
    apt-get install -y git p7zip-full \
        wget \
    && \
    rm -rf /var/lib/apt/lists/*
    
RUN mkdir /usr/src/sourcebans-${SOURCEBANS_VERSION}/ && \
    git clone https://github.com/fantasylidong/sourcebans-pp.git /sourcebans/ && \
    git clone https://github.com/aXenDeveloper/sourcebans-web-theme-fluent.git /tmp && \
    mv /tmp/sourcebans-web-theme-fluent/ /sourcebans/web/themes/ && \
    mkdir /docker/

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN savedAptMark="$(apt-mark showmanual)" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        libgmp-dev \
    && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-configure gmp && \
    docker-php-ext-install gmp mysqli pdo_mysql bcmath && \
    apt-mark auto '.*' > /dev/null && \
    apt-mark manual $savedAptMark && \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
#RUN cd /sourcebans/ && composer install

COPY docker-sourcebans-entrypoint.sh /docker/docker-sourcebans-entrypoint.sh
COPY sourcebans.ini /usr/local/etc/php/conf.d/sourcebans.ini

RUN chmod +x /docker/docker-sourcebans-entrypoint.sh

ENTRYPOINT ["/docker/docker-sourcebans-entrypoint.sh"]
CMD ["apache2-foreground"]
