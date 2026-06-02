<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly.
}

/**
 * Add custom category for patterns in the Block Editor
 *
 * @return void
 */
function sv_boilerplate_register_patterns_categories() {
	$icon = file_exists( get_template_directory() . '/dist/img/icon-site.svg' )
		? file_get_contents( get_template_directory() . '/dist/img/icon-site.svg' )
		: 'star-filled';

	register_block_pattern_category(
		'theme-fse',
		array(
			'label' => __( 'Theme Fse', 'theme-fse' ),
			'icon'  => $icon,
		)
	);
}
add_action( 'init', 'sv_boilerplate_register_patterns_categories' );

/**
 * Add custom category for blocks in the Block Editor.
 *
 * @param array                   $categories Existing block categories.
 * @param \WP_Block_Editor_Context $post      Block editor context (unused).
 * @return array Categories with the custom one prepended.
 */
function sv_boilerplate_register_blocks_categories( $categories, $post ) {
	unset( $post );
	$icon = file_exists( get_template_directory() . '/dist/img/icon-site.svg' )
		? file_get_contents( get_template_directory() . '/dist/img/icon-site.svg' )
		: 'star-filled';

	return array_merge(
		array(
			array(
				'slug'  => 'theme-fse',
				'title' => __( 'Theme Fse', 'theme-fse' ),
				'icon'  => $icon,
			),
		),
		$categories
	);
}
add_filter( 'block_categories_all', 'sv_boilerplate_register_blocks_categories', 10, 2 );
