<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly.
}

/**
 * Block XML-RPC requests for security
 */
add_filter( 'xmlrpc_enabled', '__return_false' );

/**
 * Hide WordPress version in source code and feeds.
 */
remove_action( 'wp_head', 'wp_generator' );
add_filter( 'the_generator', '__return_empty_string' );

/**
 * Disable file editing in the admin.
 */
if ( is_admin() && ! defined( 'DISALLOW_FILE_EDIT' ) ) {
	define( 'DISALLOW_FILE_EDIT', true );
}

/**
 * Disable login errors to avoid user enumeration.
 *
 * @param string $error The default login error message.
 * @return string
 */
function sv_boilerplate_hide_login_errors( $error ) {
	unset( $error );
	return __( 'Login failed. Please try again.', 'studioval-boilerplate' );
}
add_filter( 'login_errors', 'sv_boilerplate_hide_login_errors' );

/**
 * Disable directory browsing by writing "Options -Indexes" to .htaccess.
 * Uses insert_with_markers() so the block is idempotent and clearly delimited.
 *
 * @return void
 */
function sv_boilerplate_disable_directory_browsing() {
	$htaccess = ABSPATH . '.htaccess';

	if ( ! file_exists( $htaccess ) ) {
		return;
	}

	if ( ! function_exists( 'insert_with_markers' ) ) {
		require_once ABSPATH . 'wp-admin/includes/misc.php';
	}

	$existing = extract_from_markers( $htaccess, 'sv-no-indexes' );

	if ( in_array( 'Options -Indexes', $existing, true ) ) {
		return;
	}

	insert_with_markers( $htaccess, 'sv-no-indexes', array( 'Options -Indexes' ) );
}
add_action( 'init', 'sv_boilerplate_disable_directory_browsing' );

/**
 * Disable author archive scans to prevent user enumeration.
 *
 * @return void
 */
function sv_boilerplate_disable_author_archive_scans() {
	if ( is_author() && ! is_user_logged_in() ) {
		wp_safe_redirect( home_url() );
		exit;
	}
}
add_action( 'template_redirect', 'sv_boilerplate_disable_author_archive_scans' );
