<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly.
}

/**
 * Add custom category for patterns in the Block Editor
 *
 * @return void
 */
function studio_register_patterns_categories() {
	$icon = file_exists( get_template_directory() . '/dist/img/icon-site.svg' )
		? file_get_contents( get_template_directory() . '/dist/img/icon-site.svg' )
		: 'star-filled';

	register_block_pattern_category(
		'studioval-boilerplate',
		array(
			'label' => __( 'Theme Name', 'studioval-boilerplate' ),
			'icon'  => $icon,
		)
	);
}
add_filter( 'init', 'studio_register_patterns_categories' );

/**
 * Add custom category for blocks in the Block Editor
 *
 * @return void
 */
function studio_register_blocks_categories( $categories, $post ) {
	$icon = file_exists( get_template_directory() . '/dist/img/icon-site.svg' )
		? file_get_contents( get_template_directory() . '/dist/img/icon-site.svg' )
		: 'star-filled';

	return array_merge(
		array(
			array(
				'slug'  => 'studioval-boilerplate',
				'title' => __( 'Theme Name', 'studioval-boilerplate' ),
				'icon'  => $icon,
			),
		),
		$categories
	);
}
add_filter( 'block_categories_all', 'studio_register_blocks_categories', 10, 2 );
