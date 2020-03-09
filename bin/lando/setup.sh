#!/bin/bash

set -e

echo_heading() {
	echo
	echo "======================"
	echo $1
	echo "======================"
	echo
}

WP_VERSION=`curl -L http://api.wordpress.org/core/version-check/1.7/ | perl -ne '/"version":\s*"([\d\.]+)"/; print $1;'`

# Remove leftover wp-config files
rm -rf $LANDO_WEBROOT/wp-config.php

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
echo_heading "Creating wp-config"

wp config create \
	--path=$LANDO_WEBROOT \
	--dbname=$DB_NAME \
	--dbuser=$DB_USER \
	--dbpass=$DB_PASS \
	--dbhost=$DB_HOST \
	--extra-php <<PHP
// Env constants
define( 'FILES_CLIENT_SITE_ID', 200508 );

// Read-only filesystem
define( 'DISALLOW_FILE_EDIT', true );
define( 'DISALLOW_FILE_MODS', true );
define( 'AUTOMATIC_UPDATER_DISABLED', true );

// Server limits
define( 'WP_MAX_MEMORY_LIMIT', '512M' );

// Load custom error logging functions, if available
if ( file_exists( ABSPATH . '/wp-content/mu-plugins/lib/wpcom-error-handler/wpcom-error-handler.php' ) ) {
	require_once ABSPATH . '/wp-content/mu-plugins/lib/wpcom-error-handler/wpcom-error-handler.php';
}

// VIP Search
define( 'USE_VIP_ELASTICSEARCH', true );
define( 'VIP_ENABLE_ELASTICSEARCH_QUERY_INTEGRATION', true );
define( 'VIP_ELASTICSEARCH_ENDPOINTS', [
	'http://vip-search:9200',
] );
define( 'VIP_ELASTICSEARCH_USERNAME', 'test_user' );
define( 'VIP_ELASTICSEARCH_PASSWORD', 'test_password' );

// VIP Config
if ( file_exists( __DIR__ . '/wp-content/vip-config/vip-config.php' ) ) {
	require_once( __DIR__ . '/wp-content/vip-config/vip-config.php' );
}

define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );
PHP

# Install WordPress
echo_heading "Installing WordPress $WP_VERSION"

wp core install \
	--path=$LANDO_WEBROOT \
	--url="http://vip-go-dev.lndo.site" \
	'--title="VIP Go Dev"' \
	--admin_user="vipgo" \
	--admin_password="password" \
	--admin_email="vip@localhost.local" \
	--skip-email

# Setup phpunit
echo_heading "Setting up wp-tests"
if [ ! -d "$WP_TESTS_PATH" ]; then
	echo "Cloning WP Unit Tests => $WP_TESTS_PATH"
	svn co --quiet https://develop.svn.wordpress.org/tags/$WP_VERSION/tests/phpunit/includes/ $WP_TESTS_PATH/includes
	svn co --quiet https://develop.svn.wordpress.org/tags/$WP_VERSION/tests/phpunit/data/ $WP_TESTS_PATH/data
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
