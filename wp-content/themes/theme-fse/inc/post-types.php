<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly.
}

/**
 * Register Custom Post Types and Taxonomies.
 *
 * Use the `wp-create-post-type` and `wp-create-taxonomy` Claude Code skills
 * to scaffold new types with the correct labels, args, and conventions.
 */
function sv_boilerplate_register_post_types() {
	// Register your custom post types here.
}
add_action( 'init', 'sv_boilerplate_register_post_types' );
