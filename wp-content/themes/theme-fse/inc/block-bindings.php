<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly.
}

/**
 * Set custom block bindings for meta data
 *
 * @return void
 */
function sv_boilerplate_register_meta() {
	register_block_bindings_source(
		'namespace/slug',
		array(
			'label'              => '',
			'get_value_callback' => 'sv_boilerplate_callback_meta_slug',
		)
	);
}
add_action( 'init', 'sv_boilerplate_register_meta' );

function sv_boilerplate_callback_meta_slug( $source_args, $block_instance, $attribute_name ) {
	return '';
}
