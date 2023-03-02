FROM php:8.1 as php-server

RUN apt-get update -y
RUN apt-get install -y unzip libpq-dev libcurl4-gnutls-dev
RUN docker-php-ext-install pdo_mysql bcmath

RUN pecl install -o -f redis \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis

WORKDIR /var/www
# copy code files into WORKDIR folder
# COPY . .
# or
COPY . /var/www

# install composer
COPY --from=composer:2.3.5 /usr/bin/composer /usr/bin/composer

ENV PORT=8000

# Change the "entrypoint.sh" file permission before it is executed || Recommended To Do it on host machine(the one building the Docker image)
# RUN chmod +x ./docker/entrypoint.sh
# install dependencies, run migrations etc...
ENTRYPOINT [ "docker/entrypoint.sh" ]

#=====================================
# NodeJs

FROM node:14-alpine as node-server

WORKDIR /var/www
# copy code files into WORKDIR folder
# COPY . .
# or
COPY . /var/www

RUN npm install --global cross-env
RUN npm install

VOLUME /var/www/node_modules