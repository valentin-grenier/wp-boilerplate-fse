<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly
}

/**
 * Register theme options menu page
 */
function sv_boilerplate_theme_options_menu() {
	add_menu_page(
		__( 'Options du thème', 'theme-fse' ),
		__( 'Options', 'theme-fse' ),
		'manage_options',
		'sv-boilerplate-theme-options',
		'sv_boilerplate_theme_options_page',
		'dashicons-admin-generic',
		80
	);
}
add_action( 'admin_menu', 'sv_boilerplate_theme_options_menu' );

/**
 * Register theme options settings
 */
function sv_boilerplate_theme_options_register() {
	register_setting(
		'sv_boilerplate_theme_options',
		'sarbacane_api_key',
		array(
			'type'              => 'string',
			'sanitize_callback' => 'sanitize_text_field',
			'default'           => '',
			'show_in_rest'      => true,
		)
	);
}
add_action( 'init', 'sv_boilerplate_theme_options_register' );

/**
 * Enqueue admin script on the theme options page
 */
function sv_boilerplate_theme_options_assets( $hook_suffix ) {
	if ( 'toplevel_page_sv-boilerplate-theme-options' !== $hook_suffix ) {
		return;
	}

	wp_enqueue_script(
		'sv-boilerplate-admin-options',
		get_template_directory_uri() . '/dist/js/admin.bundle.js',
		array( 'wp-element', 'wp-i18n', 'wp-api-fetch', 'wp-components' ),
		filemtime( get_template_directory() . '/dist/js/admin.bundle.js' ),
		true
	);

	wp_enqueue_style(
		'sv-boilerplate-admin-options',
		get_template_directory_uri() . '/dist/css/admin.css',
		array( 'wp-components' ),
		filemtime( get_template_directory() . '/dist/css/admin.css' )
	);
}
add_action( 'admin_enqueue_scripts', 'sv_boilerplate_theme_options_assets' );

/**
 * Theme options page HTML
 */
function sv_boilerplate_theme_options_page() {
	if ( ! current_user_can( 'manage_options' ) ) {
		return;
	}

	require get_template_directory() . '/views/admin/theme-options-page.php';
}
