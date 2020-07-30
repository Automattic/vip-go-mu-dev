#!/bin/bash

set -e

set -o errexit   # exit on error
set -o errtrace  # exit on error within function/sub-shell
set -o nounset   # error on undefined vars
set -o pipefail  # error if piped command fails

echo_heading() {
	echo
	echo "======================"
	echo $1
	echo "======================"
	echo
}

WP_VERSION=`curl -L http://api.wordpress.org/core/version-check/1.7/ | perl -ne '/"version":\s*"([\d\.]+)"/; print $1;'`

# Create DB
echo_heading "Setting up database"

echo Y | mysqladmin -u$DB_USER -p$DB_PASS -h$DB_HOST drop $DB_NAME
mysqladmin -u$DB_USER -p$DB_PASS -h$DB_HOST create $DB_NAME
echo Y | mysqladmin -u$DB_USER -p$DB_PASS -h$DB_HOST drop $DB_NAME_TESTS
mysqladmin -u$DB_USER -p$DB_PASS -h$DB_HOST create $DB_NAME_TESTS

# Verify WP-CLI is ready
echo_heading "Verifying WP-CLI"
wp --version

# wp-config
echo_heading "Prepare wp-config"

# Remove leftover wp-config files
rm -rf $LANDO_WEBROOT/wp-config.php
rm -rf $LANDO_WEBROOT/config/

mkdir -p $LANDO_WEBROOT/config/
ln -sf $LANDO_MOUNT/configs/wp-config-defaults.php $LANDO_WEBROOT/config/wp-config-defaults.php

wp config create \
	--path=$LANDO_WEBROOT \
	--dbname=$DB_NAME \
	--dbuser=$DB_USER \
	--dbpass=$DB_PASS \
	--dbhost=$DB_HOST \
	--extra-php <<PHP
require( __DIR__ . '/config/wp-config-defaults.php' );
PHP

# Install WordPress
echo_heading "Installing WordPress $WP_VERSION"

wp core install \
	--path=$LANDO_WEBROOT \
	--url="http://$DOMAIN" \
	'--title="VIP Go Dev"' \
	--admin_user="vipgo" \
	--admin_password="password" \
	--admin_email="vip@localhost.local" \
	--skip-email

# Setup phpunit
echo_heading "Setting up wp-tests"
if [ ! -d "$WP_TESTS_DIR" ]; then
	echo "Cloning WP Unit Tests => $WP_TESTS_DIR"
	svn co --quiet https://develop.svn.wordpress.org/tags/$WP_VERSION/tests/phpunit/includes/ $WP_TESTS_DIR/includes
	svn co --quiet https://develop.svn.wordpress.org/tags/$WP_VERSION/tests/phpunit/data/ $WP_TESTS_DIR/data
else
	echo "wp-tests already exists; skipping"
fi

if [ ! -f "$WP_TESTS_DIR/wp-tests-config.php" ]; then
	echo "Mapping wp-tests config file"
	ln -sf $LANDO_MOUNT/configs/wp-tests-config.php $WP_TESTS_DIR/wp-tests-config.php
else
	echo "wp-tests config file already exists; skipping"
fi

# Setup Search
echo_heading "Setting up VIP Search"

wp elasticpress delete-index
wp elasticpress index --setup

# Update test user cap
echo_heading "Add to user cap"
wp user add-cap 1 view_query_monitor

# Install other wp packages you might need
echo_heading "Add other wp packages"
wp package install nlemoine/wp-cli-fixtures

