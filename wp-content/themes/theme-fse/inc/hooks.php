<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly.
}

/**
 * Exclude the theme's own dev-dependency folders (vendor, node_modules) from
 * UpdraftPlus backups.
 *
 * Scoped to the active theme directory on purpose: a global `vendor` match would
 * also drop every plugin's vendor/ folder — their runtime Composer dependencies —
 * which then fatals on restore.
 *
 * @param bool   $exclude  Whether UpdraftPlus already flagged this directory for exclusion.
 * @param string $fullpath Absolute path of the directory being considered.
 * @return bool
 */
function sv_boilerplate_exclude_theme_dev_dirs_from_backup( bool $exclude, string $fullpath ): bool {
	$theme_dir = wp_normalize_path( trailingslashit( get_template_directory() ) );
	$path      = wp_normalize_path( $fullpath );

	if ( str_starts_with( $path, $theme_dir ) ) {
		$name = basename( $path );
		if ( 'vendor' === $name || 'node_modules' === $name ) {
			return true;
		}
	}

	return $exclude;
}
add_filter( 'updraftplus_exclude_directory', 'sv_boilerplate_exclude_theme_dev_dirs_from_backup', 10, 2 );
