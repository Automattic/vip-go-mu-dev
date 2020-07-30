<?php

/**
 * These are baseline configs that are identical across all Go environments.
 */

/**
 * Read-only filesystem
 */
if ( ! defined( 'DISALLOW_FILE_EDIT' ) ) {
	define( 'DISALLOW_FILE_EDIT', true );
}

if ( ! defined( 'DISALLOW_FILE_MODS' ) ) {
	define( 'DISALLOW_FILE_MODS', true );
}

if ( ! defined( 'AUTOMATIC_UPDATER_DISABLED' ) ) {
	define( 'AUTOMATIC_UPDATER_DISABLED', true );
}

// Server limits
if ( ! defined( 'WP_MAX_MEMORY_LIMIT' ) ) {
	define( 'WP_MAX_MEMORY_LIMIT', '512M' );
}

/**
 * Error Handler
 *
 * Load custom error logging functions, if available.
 */
if ( file_exists( ABSPATH . '/wp-content/mu-plugins/lib/wpcom-error-handler/wpcom-error-handler.php' ) ) {
	require_once ABSPATH . '/wp-content/mu-plugins/lib/wpcom-error-handler/wpcom-error-handler.php';
}

/**
 * Cron Control
 */
if ( ! defined( 'WPCOM_VIP_LOAD_CRON_CONTROL_LOCALLY' ) ) {
	define( 'WPCOM_VIP_LOAD_CRON_CONTROL_LOCALLY', true );
}

if ( ! defined( 'WP_CRON_CONTROL_SECRET' ) ) {
	define( 'WP_CRON_CONTROL_SECRET', 'this-is-a-secret' );
}

/**
 * VIP Env variables
 */
if ( ! defined( 'FILES_CLIENT_SITE_ID' ) ) {
	define( 'FILES_CLIENT_SITE_ID', 200508 );
}

/**
 * VIP Config
 */
if ( file_exists( __DIR__ . '/wp-content/vip-config/vip-config.php' ) ) {
	require_once( __DIR__ . '/wp-content/vip-config/vip-config.php' );
}

/**
 * VIP Search
 */
if ( ! defined( 'USE_VIP_ELASTICSEARCH' ) ) {
	define( 'USE_VIP_ELASTICSEARCH', true );
}

if ( ! defined( 'VIP_ENABLE_ELASTICSEARCH_QUERY_INTEGRATION' ) ) {
	define( 'VIP_ENABLE_ELASTICSEARCH_QUERY_INTEGRATION', true );
}

if ( ! defined( 'VIP_ELASTICSEARCH_ENDPOINTS' ) ) {
	define( 'VIP_ELASTICSEARCH_ENDPOINTS', [
		'http://vip-search:9200',
	] );
}

if ( ! defined( 'VIP_ELASTICSEARCH_USERNAME' ) ) {
	define( 'VIP_ELASTICSEARCH_USERNAME', 'test_user' );
}

if ( ! defined( 'VIP_ELASTICSEARCH_PASSWORD' ) ) {
	define( 'VIP_ELASTICSEARCH_PASSWORD', 'test_password' );
}

/**
 * StatsD
 */
if ( ! defined( 'VIP_STATSD_HOST' ) ) {
	define( 'VIP_STATSD_HOST', 'statsd' );
}
if ( ! defined( 'VIP_STATSD_PORT' ) ) {
	define( 'VIP_STATSD_PORT', 8126 );
}

/**
 * Debugging
 */
if ( ! defined( 'WP_DEBUG' ) ) {
	define( 'WP_DEBUG', true );
}

if ( ! defined( 'WP_DEBUG_LOG' ) ) {
	define( 'WP_DEBUG_LOG', true );
}
