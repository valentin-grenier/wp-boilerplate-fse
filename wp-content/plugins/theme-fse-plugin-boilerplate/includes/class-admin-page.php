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

final class Theme_Fse_Plugin_Boilerplate_Admin_Page {

	use Theme_Fse_Plugin_Boilerplate_Singleton;

	/**
	 * Top-level "Studio Val" menu slug. Shared across every Studio Val plugin
	 * so they cohabit under a single brand entry in the WP admin sidebar.
	 *
	 * `bin/setup.sh` does NOT substitute this literal — `studioval` (bare) is
	 * the agency brand, same convention as the block namespace `studioval/`.
	 */
	private const PARENT_MENU_SLUG = 'studioval';

	/**
	 * This plugin's own sub-page slug. Substituted by `bin/setup.sh`.
	 */
	private const MENU_SLUG = 'theme-fse-plugin-boilerplate';

	/**
	 * Hook suffix returned by `add_submenu_page`. Captured at registration
	 * time so we don't have to hardcode a hook name (which is fragile when
	 * the parent slug changes).
	 */
	private string $page_hook = '';

	private function __construct() {
		add_action( 'admin_menu', array( $this, 'register_menu' ) );
		add_action( 'admin_enqueue_scripts', array( $this, 'enqueue_assets' ) );
	}

	/**
	 * Register the plugin's sub-page under the shared "Studio Val" menu.
	 */
	public function register_menu(): void {
		self::ensure_parent_menu();

		$hook = add_submenu_page(
			self::PARENT_MENU_SLUG,
			__( 'Plugin Boilerplate', 'theme-fse-plugin-boilerplate' ),
			__( 'Plugin Boilerplate', 'theme-fse-plugin-boilerplate' ),
			'manage_options',
			self::MENU_SLUG,
			array( $this, 'render_page' )
		);

		if ( is_string( $hook ) ) {
			$this->page_hook = $hook;
		}
	}

	/**
	 * Register the shared "Studio Val" top-level menu once.
	 *
	 * Idempotent across plugins — the first Studio Val plugin to load creates
	 * the parent, the rest see it already in `$admin_page_hooks` and skip.
	 *
	 * The parent itself has no landing page (`__return_null`); WordPress would
	 * normally synthesise a duplicate first sub-entry pointing back at the
	 * parent, so we hide it on a late `admin_menu` priority once every real
	 * sub-page has had a chance to register.
	 */
	private static function ensure_parent_menu(): void {
		global $admin_page_hooks;

		if ( isset( $admin_page_hooks[ self::PARENT_MENU_SLUG ] ) ) {
			return;
		}

		add_menu_page(
			'Studio Val',
			'Studio Val',
			'manage_options',
			self::PARENT_MENU_SLUG,
			'__return_null',
			self::get_menu_icon(),
			30
		);

		add_action(
			'admin_menu',
			static function (): void {
				remove_submenu_page( self::PARENT_MENU_SLUG, self::PARENT_MENU_SLUG );
			},
			PHP_INT_MAX
		);
	}

	/**
	 * Resolve the brand icon for the parent menu.
	 *
	 * Looks for `assets/icons/studioval.svg` and inlines it as a base64
	 * data URI so the icon ships with the plugin without an extra HTTP
	 * round-trip. Falls back to a generic dashicon if the file is missing,
	 * so the menu never disappears mid-development.
	 *
	 * Authoring tips for the SVG:
	 * - 20×20 viewBox, single-color silhouette.
	 * - Use `fill="#a7aaad"` (default WP admin sidebar text colour) so the
	 *   icon blends with the surrounding menu entries.
	 */
	private static function get_menu_icon(): string {
		$svg_path = THEME_FSE_PLUGIN_BOILERPLATE_DIR . 'assets/icons/studioval.svg';

		if ( ! is_readable( $svg_path ) ) {
			return 'dashicons-admin-generic';
		}

		// phpcs:ignore WordPress.WP.AlternativeFunctions.file_get_contents_file_get_contents -- Reading a static plugin asset shipped with the code, not a remote fetch.
		$svg = file_get_contents( $svg_path );
		if ( false === $svg || '' === $svg ) {
			return 'dashicons-admin-generic';
		}

		// phpcs:ignore WordPress.PHP.DiscouragedPHPFunctions.obfuscation_base64_encode -- Standard data-URI encoding for an inline menu icon, not obfuscation.
		return 'data:image/svg+xml;base64,' . base64_encode( $svg );
	}

	/**
	 * The mount node — React picks it up from JS.
	 */
	public function render_page(): void {
		?>
		<div class="wrap">
			<div id="theme-fse-plugin-boilerplate-app"></div>
		</div>
		<?php
	}

	/**
	 * Enqueue the admin app on its own page only — never globally.
	 *
	 * @param string $hook Current admin page hook.
	 */
	public function enqueue_assets( string $hook ): void {
		if ( '' === $this->page_hook || $this->page_hook !== $hook ) {
			return;
		}

		$asset_file = dirname( __DIR__ ) . '/dist/admin.asset.php';
		$asset      = file_exists( $asset_file )
			? require $asset_file
			: array(
				'dependencies' => array(),
				'version'      => THEME_FSE_PLUGIN_BOILERPLATE_VERSION,
			);

		wp_enqueue_script(
			'theme-fse-plugin-boilerplate-admin',
			THEME_FSE_PLUGIN_BOILERPLATE_URL . 'dist/admin.js',
			$asset['dependencies'],
			$asset['version'],
			true
		);

		wp_set_script_translations(
			'theme-fse-plugin-boilerplate-admin',
			'theme-fse-plugin-boilerplate',
			THEME_FSE_PLUGIN_BOILERPLATE_DIR . 'languages'
		);

		wp_enqueue_style(
			'theme-fse-plugin-boilerplate-admin',
			THEME_FSE_PLUGIN_BOILERPLATE_URL . 'dist/admin.css',
			array( 'wp-components' ),
			$asset['version']
		);

		// When you wire REST or any server-passed data, expose it here:
		// wp_localize_script(
		// 'theme-fse-plugin-boilerplate-admin',
		// 'themeFsePluginBoilerplateData',
		// array(
		// 'nonce' => wp_create_nonce( 'wp_rest' ),
		// ...
		// )
		// );
	}
}
