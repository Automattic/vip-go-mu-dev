<?php

// FIXME: Not working in a simple local environment, as it activates http-concat, which needs nginx support
//define( 'WPCOM_IS_VIP_ENV', true );

require( dirname( __FILE__ ) . '/config/wp-config.php' );
require_once( ABSPATH . 'wp-settings.php' );

