#!/bin/bash
export redis_ipAddress=$redis_ip
echo "Redis IP: $redis_ipAddress"
if [ ! -f "vendor/autoload.ph"]; then
    #avoid interaction with composer that may interrupt our script.No confirmations or progress showing
    echo "Installing composer dependencies"
    composer install --no-progress --no-interaction
else
    echo "composer dependencies already installed"
fi

if [ ! -f ".env"]; then
    echo "Creating .env file... for environment $APP_ENV" #APP_ENV is accessed from "Dockerfile" or docker-compose.yml where it was defined
    cp .env.example .env
else
    echo ".env file exist. No need to create new one"
fi

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
