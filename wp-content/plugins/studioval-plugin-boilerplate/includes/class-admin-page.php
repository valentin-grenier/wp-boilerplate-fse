<?php
/**
 * Admin page — registers the menu entry, renders the mount node, and enqueues
 * the React/Gutenberg-components bundle that takes over from there.
 *
 * @package Studioval\Plugin_Boilerplate
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

final class Studioval_Plugin_Boilerplate_Admin_Page {

	use Studioval_Plugin_Boilerplate_Singleton;

	private const MENU_SLUG = 'studioval-plugin-boilerplate';
	private const PAGE_HOOK = 'settings_page_studioval-plugin-boilerplate';

	private function __construct() {
		add_action( 'admin_menu', array( $this, 'register_menu' ) );
		add_action( 'admin_enqueue_scripts', array( $this, 'enqueue_assets' ) );
	}

	/**
	 * Add a sub-menu under Settings.
	 */
	public function register_menu(): void {
		add_options_page(
			__( 'Plugin Boilerplate', 'studioval-plugin-boilerplate' ),
			__( 'Plugin Boilerplate', 'studioval-plugin-boilerplate' ),
			'manage_options',
			self::MENU_SLUG,
			array( $this, 'render_page' )
		);
	}

	/**
	 * The mount node — React picks it up from JS.
	 */
	public function render_page(): void {
		?>
		<div class="wrap">
			<div id="studioval-plugin-boilerplate-app"></div>
		</div>
		<?php
	}

	/**
	 * Enqueue the admin app on its own page only — never globally.
	 *
	 * @param string $hook Current admin page hook.
	 */
	public function enqueue_assets( string $hook ): void {
		if ( self::PAGE_HOOK !== $hook ) {
			return;
		}

		$asset_file = dirname( __DIR__ ) . '/dist/admin.asset.php';
		$asset      = file_exists( $asset_file )
			? require $asset_file
			: array(
				'dependencies' => array(),
				'version'      => STUDIOVAL_PLUGIN_BOILERPLATE_VERSION,
			);

		wp_enqueue_script(
			'studioval-plugin-boilerplate-admin',
			STUDIOVAL_PLUGIN_BOILERPLATE_URL . 'dist/admin.js',
			$asset['dependencies'],
			$asset['version'],
			true
		);

		wp_set_script_translations(
			'studioval-plugin-boilerplate-admin',
			'studioval-plugin-boilerplate',
			STUDIOVAL_PLUGIN_BOILERPLATE_DIR . 'languages'
		);

		wp_enqueue_style(
			'studioval-plugin-boilerplate-admin',
			STUDIOVAL_PLUGIN_BOILERPLATE_URL . 'dist/admin.css',
			array( 'wp-components' ),
			$asset['version']
		);

		wp_localize_script(
			'studioval-plugin-boilerplate-admin',
			'studiovalPluginBoilerplateData',
			array(
				'nonce'      => wp_create_nonce( 'wp_rest' ),
				'optionName' => Studioval_Plugin_Boilerplate_Settings::OPTION_NAME,
				'settings'   => Studioval_Plugin_Boilerplate_Settings::get(),
				'defaults'   => Studioval_Plugin_Boilerplate_Settings::defaults(),
			)
		);
	}
}
