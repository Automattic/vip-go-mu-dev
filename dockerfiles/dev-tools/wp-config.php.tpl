<?php

define( 'DB_NAME', 'wordpress' );
define( 'DB_USER', 'wordpress' );
define( 'DB_PASSWORD', 'wordpress' );
define( 'DB_HOST', '%DB_HOST%' );

define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

$table_prefix = 'wp_';

require( __DIR__ . '/wp-config-defaults.php' );

