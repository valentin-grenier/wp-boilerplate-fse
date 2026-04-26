<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly.
}

/**
 * Allow SVG images to be uploaded securely
 *
 * @param array $mimes Allowed MIME types.
 * @return array
 */
function sv_boilerplate_allow_svg_uploads( $mimes ) {
	if ( current_user_can( 'manage_options' ) ) {
		$mimes['svg'] = 'image/svg+xml';
	}

	return $mimes;
}
add_filter( 'upload_mimes', 'sv_boilerplate_allow_svg_uploads' );

/**
 * Sanitize SVG files by stripping scripts/styles/entities.
 *
 * @param string $file Path to the uploaded file.
 * @return void
 */
function sv_boilerplate_sanitize_svg_file( $file ) {
	if (
		pathinfo( $file, PATHINFO_EXTENSION ) === 'svg' &&
		current_user_can( 'manage_options' )
	) {
		// phpcs:ignore WordPress.WP.AlternativeFunctions.file_get_contents_file_get_contents -- local upload path, not a remote URL.
		$svg = file_get_contents( $file );

		// Remove script/style/foreignObject tags.
		$svg = preg_replace( '/<(script|style|foreignObject).*?<\/\1>/is', '', $svg );

		// Strip all on* attributes (like onload, onclick).
		$svg = preg_replace( '/ on\w+="[^"]*"/i', '', $svg );
		$svg = preg_replace( "/ on\w+='[^']*'/i", '', $svg );

		// phpcs:ignore WordPress.WP.AlternativeFunctions.file_system_operations_file_put_contents -- local upload path, writing sanitized content back.
		file_put_contents( $file, $svg );
	}
}
add_action(
	'wp_handle_upload',
	function ( $upload ) {
		sv_boilerplate_sanitize_svg_file( $upload['file'] );
		return $upload;
	}
);

/**
 * Allow WebP images to be uploaded securely
 *
 * @param array $mimes Allowed MIME types.
 * @return array
 */
function sv_boilerplate_allow_webp_uploads( $mimes ) {
	if ( current_user_can( 'manage_options' ) ) {
		$mimes['webp'] = 'image/webp';
	}

	return $mimes;
}
add_filter( 'upload_mimes', 'sv_boilerplate_allow_webp_uploads' );

/**
 * Fix incorrect filetype detection for WebP images on some servers.
 *
 * @param array  $data     File type data.
 * @param string $file     Full path to the file.
 * @param string $filename File name.
 * @param mixed  $_mimes   Allowed mime types (unused — required by WP hook signature).
 * @return array
 */
function sv_boilerplate_fix_webp_filetype( $data, $file, $filename, $_mimes ) { // phpcs:ignore Generic.CodeAnalysis.UnusedFunctionParameter.FoundAfterLastUsed
	if ( false !== strpos( $filename, '.webp' ) ) {
		$data['ext']  = 'webp';
		$data['type'] = 'image/webp';
	}
	return $data;
}
add_filter( 'wp_check_filetype_and_ext', 'sv_boilerplate_fix_webp_filetype', 10, 4 );
