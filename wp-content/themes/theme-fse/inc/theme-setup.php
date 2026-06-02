<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly.
}

/**
 * Set up theme defaults and supports.
 *
 * @return void
 */
function sv_boilerplate_theme_setup() {
	// Translations.
	load_theme_textdomain( 'theme-fse', get_template_directory() . '/languages' );

	// Theme supports.
	add_theme_support( 'title-tag' );
	add_theme_support( 'post-thumbnails' );
	add_theme_support(
		'html5',
		array(
			'search-form',
			'comment-form',
			'comment-list',
			'gallery',
			'caption',
			'script',
			'style',
		)
	);
	add_theme_support( 'responsive-embeds' );

	// Editor styles: load the compiled front-end stylesheet inside the block editor
	// so the editing surface mirrors the front-end render.
	add_theme_support( 'editor-styles' );
	add_editor_style( 'dist/css/theme.css' );

	// Remove core block patterns and block directory suggestions.
	remove_action( 'enqueue_block_editor_assets', 'wp_enqueue_editor_block_directory_assets' );
	remove_theme_support( 'core-block-patterns' );

	// Clean up <head>.
	remove_action( 'wp_head', 'wlwmanifest_link' );
	remove_action( 'wp_head', 'rsd_link' );
}
add_action( 'after_setup_theme', 'sv_boilerplate_theme_setup' );

/**
 * Add custom <meta> tags to the head.
 *
 * @return void
 */
function sv_boilerplate_add_head_meta() {
	// echo '<meta name="google-site-verification" content="12345" />';
}
add_action( 'wp_head', 'sv_boilerplate_add_head_meta' );

/**
 * Sanitize filenames by removing accents.
 */
add_filter( 'sanitize_file_name', 'remove_accents' );
