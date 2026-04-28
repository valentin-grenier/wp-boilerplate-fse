<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly.
}

/**
 * Remove block style variations in the editor
 *
 * @return void
 */
function sv_boilerplate_remove_block_style_variations() {
	wp_enqueue_script(
		'studio-script-unregister-style-variations',
		get_template_directory_uri() . '/assets/js/editor/unregister-style-variations.js',
		array( 'wp-blocks', 'wp-dom-ready', 'wp-edit-post' ),
		wp_get_theme()->get( 'Version' ),
		true
	);
}
add_action( 'enqueue_block_editor_assets', 'sv_boilerplate_remove_block_style_variations' );

/**
 * Remove blocks from the Block Editor
 *
 * @return void
 */
function sv_boilerplate_unregister_comment_blocks_script() {
	wp_enqueue_script(
		'studio-unregister-comment-blocks',
		get_template_directory_uri() . '/assets/js/editor/unregister-blocks.js',
		array( 'wp-blocks', 'wp-dom-ready', 'wp-edit-post' ),
		wp_get_theme()->get( 'Version' ),
		true
	);
}
add_action( 'enqueue_block_editor_assets', 'sv_boilerplate_unregister_comment_blocks_script' );

/**
 * Remove heading levels from the Block Editor.
 *
 * @param array  $args       Block args being filtered.
 * @param string $block_type Block type name.
 * @return array
 */
function sv_boilerplate_remove_heading_levels( $args, $block_type ) {
	if ( 'core/heading' !== $block_type ) {
		return $args;
	}

	// Allow only levels 1, 2, and 3.
	$args['attributes']['levelOptions']['default'] = array( 1, 2, 3 );

	return $args;
}
add_filter( 'register_block_type_args', 'sv_boilerplate_remove_heading_levels', 10, 2 );
