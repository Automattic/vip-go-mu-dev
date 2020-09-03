<?php
 
/*
Plugin Name: Memcached
Description: Memcached backend for the WP Object Cache.
Version: 3.0.1
Plugin URI: http://wordpress.org/extend/plugins/memcached/
Author: Automattic
 
Install this file to wp-content/object-cache.php
*/
 
define( 'VIP_OBJECT_CACHE_DROPIN_STABLE', __DIR__ .'/object-cache-stable.php' );
define( 'VIP_OBJECT_CACHE_DROPIN_NEXT', __DIR__ .'/object-cache-next.php' );

// If site is testing next version of object cache dropin, load it
if ( defined( 'VIP_USE_NEXT_OBJECT_CACHE_DROPIN' ) && true === VIP_USE_NEXT_OBJECT_CACHE_DROPIN && is_readable( VIP_OBJECT_CACHE_DROPIN_NEXT ) ) {
	require_once( VIP_OBJECT_CACHE_DROPIN_NEXT );
} else {
	// Else, load stable cache dropin (default)
	require_once( VIP_OBJECT_CACHE_DROPIN_STABLE );
}

