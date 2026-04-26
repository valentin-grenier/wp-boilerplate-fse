<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly.
}

/**
 * Allow every Block Editor features for administrators
 *
 * @param WP_Theme_JSON_Data $theme_json The theme JSON data.
 * @return WP_Theme_JSON_Data
 */
function sv_boilerplate_grant_admin_block_editor_capabilities( $theme_json ) {
	if ( ! current_user_can( 'edit_theme_options' ) ) {
		return $theme_json;
	}

	$caps_file = get_theme_file_path( 'admin-caps.json' );

	if ( ! file_exists( $caps_file ) ) {
		return $theme_json;
	}

	// phpcs:ignore WordPress.WP.AlternativeFunctions.file_get_contents_file_get_contents -- local theme file, not a remote URL.
	$new_data = json_decode( file_get_contents( $caps_file ), true );

	if ( ! is_array( $new_data ) ) {
		return $theme_json;
	}

	return $theme_json->update_with( $new_data );
}
add_filter( 'wp_theme_json_data_theme', 'sv_boilerplate_grant_admin_block_editor_capabilities' );
