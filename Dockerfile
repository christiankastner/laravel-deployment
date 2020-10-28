FROM php:7.4-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip 

# Install Node
RUN apt-get install -y gnupg2

RUN rm -rf /var/lib/apt/lists/ && curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install nodejs -y


# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
# RUN useradd -G www-data,root -u 1000 -d /home/www-data www-data
RUN mkdir -p /home/www-data/.composer && \
    chown -R www-data:www-data /home/www-data

# Set working directory
WORKDIR /var/www/

ADD ./src /var/www/

RUN chown -R www-data:www-data /var/www

COPY dump.sql /dump.sql

USER www-data

RUN npm i
RUN npm run dev


RUN composer install

CMD php artisan serve --port=8000 --host=0.0.0.0

EXPOSE 8000


# ENTRYPOINT [ "/laravel-entrypoint.sh" ]