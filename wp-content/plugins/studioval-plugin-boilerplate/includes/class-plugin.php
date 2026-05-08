<?php
/**
 * Main plugin bootstrap.
 *
 * Wires up every singleton component. Add new components here as the plugin grows
 * (e.g. `Studioval_Plugin_Boilerplate_Settings::instance();`).
 *
 * @package Studioval\Plugin_Boilerplate
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

final class Studioval_Plugin_Boilerplate_Plugin {

	use Studioval_Plugin_Boilerplate_Singleton;

	/**
	 * Boot every component once.
	 */
	private function __construct() {
		Studioval_Plugin_Boilerplate_Admin_Page::instance();
	}
}
