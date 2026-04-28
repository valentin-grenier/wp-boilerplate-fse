<?php
/**
 * Plugin Name:       Studio Val • Custom Login Page
 * Plugin URI:        https://studio-val.fr
 * Description:       Customize the WordPress login page with layouts, colors, branding and more.
 * Version:           1.0.0
 * Author:            Valentin Grenier • Studio Val
 * Author URI:        https://github.com/valentin-grenier/
 * License:           GPL-2.0-or-later
 * License URI:       https://www.gnu.org/licenses/gpl-2.0.html
 * Text Domain:       studioval-clp
 * Domain Path:       /languages
 * Requires at least: 6.3
 * Requires PHP:      8.1
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

define( 'STUDIOVAL_CLP_VERSION', '1.0.0' );
define( 'STUDIOVAL_CLP_DIR', plugin_dir_path( __FILE__ ) );
define( 'STUDIOVAL_CLP_URL', plugin_dir_url( __FILE__ ) );

require_once STUDIOVAL_CLP_DIR . 'includes/class-settings-page.php';
require_once STUDIOVAL_CLP_DIR . 'includes/class-login-customizer.php';

add_action( 'plugins_loaded', function () {
	load_plugin_textdomain( 'studioval-clp', false, dirname( plugin_basename( __FILE__ ) ) . '/languages' );

	( new StudioVal_CLP_Settings_Page() )->init();
	( new StudioVal_CLP_Login_Customizer() )->init();
} );
