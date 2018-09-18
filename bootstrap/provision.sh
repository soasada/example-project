#!/bin/bash

# Update system
apt-get update -y && apt-get upgrade -y

# Install nginx
apt-get -y install nginx

service nginx start

# Install php 7.2
apt-get -y install php

# Install php 7.2 modules
apt-get install -y unzip zip php-pear php-fpm php-dev php-zip php-curl php-xmlrpc php-gd php-mysql php-mbstring php-xml

service php7.2-fpm start

rm -f /etc/nginx/sites-enabled/default

echo "server {
    server_name localhost;
    root /var/www/clickferry/public;

    location / {
        try_files \$uri /index.php\$is_args\$args;
    }

    location ~ ^/index\.php(/|\$) {
        fastcgi_pass unix:/run/php/php7.2-fpm.sock;
        fastcgi_split_path_info ^(.+\.php)(/.*)\$;
        include fastcgi_params;

        # optionally set the value of the environment variables used in the application
        # fastcgi_param APP_ENV prod;
        # fastcgi_param APP_SECRET <app-secret-id>;
        # fastcgi_param DATABASE_URL \"mysql://db_user:db_pass@host:3306/db_name\";

        # When you are using symlinks to link the document root to the
        # current version of your application, you should pass the real
        # application path instead of the path to the symlink to PHP
        # FPM.
        # Otherwise, PHP's OPcache may not properly detect changes to
        # your PHP files (see https://github.com/zendtech/ZendOptimizerPlus/issues/126
        # for more information).
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        fastcgi_param DOCUMENT_ROOT \$realpath_root;
        # Prevents URIs that include the front controller. This will 404:
        # http://domain.tld/index.php/some-path
        # Remove the internal directive to allow URIs like this
        internal;
    }

    location ~ \.php\$ {
        return 404;
    }

    error_log /var/log/nginx/project_error.log;
    access_log /var/log/nginx/project_access.log;
}" > /etc/nginx/sites-available/clickferry

ln -s /etc/nginx/sites-available/clickferry /etc/nginx/sites-enabled/clickferry
rm -f /var/www/html/index.nginx-debian.html
service nginx restart
service php7.2-fpm restart

# Install xdebug
apt-get -y install php-xdebug

read -r -d '' XDEBUG_CONF << ROTO
xdebug.remote_enable=1
xdebug.remote_handler=dbgp
xdebug.remote_mode=req
xdebug.remote_host=$1
xdebug.remote_port=9000
xdebug.remote_autostart=1
ROTO

echo "$XDEBUG_CONF" >> /etc/php/7.2/fpm/conf.d/20-xdebug.ini

# Install MySQL
debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
apt-get -y install mysql-server

mysql -uroot -proot -e "CREATE DATABASE clickferry"

# Install composer

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
ln -s /home/vagrant/composer.phar /usr/bin/composer

sed -i 's/user = www-data/user = vagrant/g' /etc/php/7.2/fpm/pool.d/www.conf
sed -i 's/group = www-data/group = vagrant/g' /etc/php/7.2/fpm/pool.d/www.conf

service nginx restart
service php7.2-fpm restart

# Install yarn JS dependency management
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
apt-get -y update
apt-get -y install yarn