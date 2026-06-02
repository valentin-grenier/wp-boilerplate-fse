<?php
/**
 * Uninstall handler.
 *
 * Runs when the plugin is deleted from the WordPress admin (not on deactivation).
 * Add cleanup for whatever the plugin persists — options, custom tables, scheduled
 * events, transients — so a clean slate is left behind.
 *
 * Example:
 *   delete_option( 'theme_fse_plugin_boilerplate_settings' );
 *
 * @package Studioval\Plugin_Boilerplate
 */

if ( ! defined( 'WP_UNINSTALL_PLUGIN' ) ) {
	exit;
}
