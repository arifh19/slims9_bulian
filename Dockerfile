FROM php:7.4-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    unzip libfreetype6-dev libjpeg62-turbo-dev libpng-dev zlib1g-dev libzip-dev libbz2-dev libonig-dev yaz libyaz-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure gd
RUN docker-php-ext-install -j$(nproc) pdo_mysql gd exif zip gettext
RUN pecl install yaz && docker-php-ext-enable yaz

# Set working directory
WORKDIR /var/www

# Apache configs + document root.
ENV APACHE_DOCUMENT_ROOT=/var/www
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# mod_rewrite for URL rewrite and mod_headers for .htaccess extra headers like Access-Control-Allow-Origin-
RUN a2enmod rewrite headers

# Copy application source
COPY . .

CMD ["apache2-foreground"]