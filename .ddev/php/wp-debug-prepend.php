<?php
// Loaded before wp-config.php, so these win over the defined()||define() in
// wp-config-ddev.php, which DDEV regenerates on every start.
defined( 'WP_DEBUG_DISPLAY' ) || define( 'WP_DEBUG_DISPLAY', false );
defined( 'WP_DEBUG_LOG' )     || define( 'WP_DEBUG_LOG', true );
