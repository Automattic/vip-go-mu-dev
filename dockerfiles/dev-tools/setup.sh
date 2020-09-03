#!/bin/sh

if [ $# -lt 4 ]; then
  echo: "Syntax: setup.sh <db_host> <db_admin_user> <wp_url> <wp_title>"
  exit 1
fi

if [ -r /wp/config/wp-config.php ]; then
  echo "Already existing WordPress installation"
  exit 0
fi

db_host=$1
db_admin_user=$2
wp_url=$3
wp_title=$4

echo "GRANT ALL ON *.* TO 'wordpress'@'localhost' IDENTIFIED BY 'wordpress' WITH GRANT OPTION;" | mysql -h $db_host -u root
echo "GRANT ALL ON *.* TO 'wordpress'@'%' IDENTIFIED BY 'wordpress' WITH GRANT OPTION;" | mysql -h database -u root
echo "CREATE DATABASE wordpress;" | mysql -h database -u root

cp /dev-tools/wp-config-defaults.php /wp/config/
cat /dev-tools/wp-config.php.tpl | sed -e "s/%DB_HOST%/$db_host/" > /wp/config/wp-config.php
curl -s https://api.wordpress.org/secret-key/1.1/salt/ >> /wp/config/wp-config.php

wp core install \
  --url="$wp_url" \
  --title="$wp_title" \
  --admin_user="vipgo" \
  --admin_email="vip@localhost.local" \
  --skip-email \
  --admin_password="password" \
  --path=/wp \
  --allow-root #2>/dev/null

wp --allow-root elasticpress delete-index
wp --allow-root elasticpress index --setup

wp --allow-root user add-cap 1 view_query_monitor
