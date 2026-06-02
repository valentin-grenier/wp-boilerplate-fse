<?php
/**
 * Plugin Name:       Studio Val • Theme Fse Plugin Boilerplate
 * Plugin URI:        https://studio-val.fr
 * Description:       Blank scaffold for custom WordPress plugins. Singleton classes, empty React admin page, webpack-built. Add your own logic on top.
 * Version:           1.0.0
 * Author:            Valentin Grenier • Studio Val
 * Author URI:        https://github.com/valentin-grenier/
 * License:           GPL-2.0-or-later
 * License URI:       https://www.gnu.org/licenses/gpl-2.0.html
 * Text Domain:       theme-fse-plugin-boilerplate
 * Domain Path:       /languages
 * Requires at least: 6.3
 * Requires PHP:      8.1
 *
 * @package Studioval\Plugin_Boilerplate
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

define( 'THEME_FSE_PLUGIN_BOILERPLATE_VERSION', '1.0.0' );
define( 'THEME_FSE_PLUGIN_BOILERPLATE_FILE', __FILE__ );
define( 'THEME_FSE_PLUGIN_BOILERPLATE_DIR', plugin_dir_path( __FILE__ ) );
define( 'THEME_FSE_PLUGIN_BOILERPLATE_URL', plugin_dir_url( __FILE__ ) );

require_once THEME_FSE_PLUGIN_BOILERPLATE_DIR . 'includes/trait-singleton.php';
require_once THEME_FSE_PLUGIN_BOILERPLATE_DIR . 'includes/class-admin-page.php';
require_once THEME_FSE_PLUGIN_BOILERPLATE_DIR . 'includes/class-plugin.php';

add_action(
	'plugins_loaded',
	static function () {
		load_plugin_textdomain(
			'theme-fse-plugin-boilerplate',
			false,
			dirname( plugin_basename( THEME_FSE_PLUGIN_BOILERPLATE_FILE ) ) . '/languages'
		);

		Theme_Fse_Plugin_Boilerplate_Plugin::instance();
	}
);
