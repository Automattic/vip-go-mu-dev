#!/bin/sh

if [ $# -lt 4 ]; then
  echo: "Syntax: setup.sh <db_host> <db_admin_user> <wp_domain> <wp_title> [<multisite_domain>]"
  exit 1
fi

# FIXME: Also check if the DB exists
if [ -r /wp/config/wp-config.php ]; then
  echo "Already existing WordPress installation"
  exit 0
fi

db_host=$1
db_admin_user=$2
wp_url=$3
wp_title=$4
multisite_domain=$5

echo "GRANT ALL ON *.* TO 'wordpress'@'localhost' IDENTIFIED BY 'wordpress' WITH GRANT OPTION;" | mysql -h $db_host -u root
echo "GRANT ALL ON *.* TO 'wordpress'@'%' IDENTIFIED BY 'wordpress' WITH GRANT OPTION;" | mysql -h database -u root
echo "CREATE DATABASE wordpress;" | mysql -h database -u root

cp /dev-tools/wp-config-defaults.php /wp/config/
cat /dev-tools/wp-config.php.tpl | sed -e "s/%DB_HOST%/$db_host/" > /wp/config/wp-config.php
if [ -n "$multisite_domain" ]; then
  cat /dev-tools/wp-config-multisite.php.tpl | sed -e "s/%DOMAIN%/$multisite_domain/" >> /wp/config/wp-config.php
fi
curl -s https://api.wordpress.org/secret-key/1.1/salt/ >> /wp/config/wp-config.php

if [ -n "$multisite_domain" ]; then
  wp core multisite-install \
    --path=/wp \
    --allow-root \
    --url="$wp_url" \
    --title="$wp_title" \
    --admin_user="vipgo" \
    --admin_email="vip@localhost.local" \
    --admin_password="password" \
    --skip-email \
    --skip-plugins \
    --subdomains \
    --skip-config #2>/dev/null
else
  wp core install \
    --path=/wp \
    --allow-root \
    --url="$wp_url" \
    --title="$wp_title" \
    --admin_user="vipgo" \
    --admin_email="vip@localhost.local" \
    --admin_password="password" \
    --skip-email \
    --skip-plugins #2>/dev/null
fi

wp --allow-root elasticpress delete-index
wp --allow-root elasticpress index --setup

wp --allow-root user add-cap 1 view_query_monitor
