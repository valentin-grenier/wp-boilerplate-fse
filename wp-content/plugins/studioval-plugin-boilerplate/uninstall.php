<?php
/**
 * Uninstall handler.
 *
 * Runs when the plugin is deleted from the WordPress admin (not on deactivation).
 * Removes the option created by the plugin so a clean slate is left behind.
 *
 * @package Studioval\Plugin_Boilerplate
 */

if ( ! defined( 'WP_UNINSTALL_PLUGIN' ) ) {
	exit;
}

delete_option( 'studioval_plugin_boilerplate_settings' );
