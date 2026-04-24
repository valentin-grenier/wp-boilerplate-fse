<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly.
}

/**
 * Exclude node_modules directories from UpdraftPlus backups.
 */
function studio_exclude_node_modules_from_backup( bool $exclude, string $dir ): bool {
	if ( str_contains( $dir, 'node_modules' ) || str_contains( $dir, 'vendor' ) ) {
		return true;
	}
	return $exclude;
}
add_filter( 'updraftplus_exclude_directory', 'studio_exclude_node_modules_from_backup', 10, 2 );
