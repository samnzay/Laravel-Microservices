#!/bin/bash

if [ ! -f "vendor/autoload.ph" ]; then
    #avoid interaction with composer that may interrupt our script.No confirmations or progress showing
    echo "Installing composer dependencies"
    composer install --no-progress --no-interaction
else
    echo "composer dependencies already installed"
fi

if [ ! -f ".env" ]; then
    echo "Creating .env file... for environment $APP_ENV " #APP_ENV is accessed from "Dockerfile" or docker-compose.yml where it was defined
    cp .env.example .env
else
    echo ".env file exist. No need to create new one"
fi

server_role=${CONTAINER_ROLE:-app}

if [ "$server_role" = "app" ]; then

    php artisan migrate
    php artisan key:generate
    php artisan cache:clear
    php artisan config:clear
    php artisan route:clear

    # php artisan clear-compiled 
    # composer dump-autoload -o
    # php artisan optimize

    php artisan serve --port=$PORT --host=0.0.0.0  --env=.env # Port defined in ENV Dockerfile, Specify .env file
    exec docker-php-entrypoint "$@" # execute default docker php entrypoint

elif  [ "$server_role" = "queue" ]; then
    echo "running Queue Server..."
    php /var/www/artisan queue:work --verbose --tries=3 --timeout=180

elif [ "$server_role" = "websocket" ]; then
    echo "running Websockets Server..."
    php artisan websockets:serve
fi