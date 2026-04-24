<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly.
}

/**
 * Register custom ACF blocks for the Block Editor
 */

function sv_boilerplate_register_acf_blocks() {
	$block_json_files = glob( get_template_directory() . '/_dev/blocks/*/block.json' );

	foreach ( $block_json_files as $block_json_file ) {
		register_block_type( $block_json_file );
	}
}
add_action( 'acf/init', 'sv_boilerplate_register_acf_blocks' );
