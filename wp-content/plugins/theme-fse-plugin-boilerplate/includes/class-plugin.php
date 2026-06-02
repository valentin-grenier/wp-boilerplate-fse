<?php
/**
 * Main plugin bootstrap.
 *
 * Wires up every singleton component. Add new components here as the plugin grows
 * (e.g. `Theme_Fse_Plugin_Boilerplate_Settings::instance();`).
 *
 * @package Studioval\Plugin_Boilerplate
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

final class Theme_Fse_Plugin_Boilerplate_Plugin {

	use Theme_Fse_Plugin_Boilerplate_Singleton;

	/**
	 * Boot every component once.
	 */
	private function __construct() {
		Theme_Fse_Plugin_Boilerplate_Admin_Page::instance();
	}
}
