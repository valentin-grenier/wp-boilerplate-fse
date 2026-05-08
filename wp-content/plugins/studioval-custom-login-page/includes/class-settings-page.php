<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

class StudioVal_CLP_Settings_Page {

	const OPTION_NAME = 'studioval_clp_settings';

	/**
	 * Top-level "Studio Val" menu slug. Shared with every other Studio Val
	 * plugin so they cohabit under a single brand entry. `studioval` (bare)
	 * is the agency's brand literal and is preserved across `bin/setup.sh`.
	 */
	const PARENT_MENU_SLUG = 'studioval';

	/**
	 * Hook suffix returned by `add_submenu_page` — captured at registration
	 * time, used to gate the asset enqueue.
	 */
	private string $page_hook = '';

	public function init(): void {
		add_action( 'admin_menu', [ $this, 'add_menu_page' ] );
		add_action( 'admin_enqueue_scripts', [ $this, 'enqueue_scripts' ] );
		add_action( 'rest_api_init', [ $this, 'register_settings' ] );
	}

	public function add_menu_page(): void {
		self::ensure_parent_menu();

		$hook = add_submenu_page(
			self::PARENT_MENU_SLUG,
			__( 'Custom login', 'studioval-clp' ),
			__( 'Custom login', 'studioval-clp' ),
			'manage_options',
			'studioval-custom-login',
			[ $this, 'render_page' ]
		);

		if ( is_string( $hook ) ) {
			$this->page_hook = $hook;
		}
	}

	/**
	 * Register the shared "Studio Val" top-level menu once.
	 *
	 * Idempotent: every Studio Val plugin can call this; the first to load
	 * creates the parent, the rest see it in `$admin_page_hooks` and skip.
	 * Hides the auto-synthesised duplicate sub-entry on a late `admin_menu`
	 * priority once every real sub-page has had a chance to register.
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
	 * Resolve the brand icon. Reads `assets/icons/studioval.svg` shipped
	 * with the plugin and inlines it as a base64 data URI. Falls back to
	 * a generic dashicon when the file is missing so the menu never
	 * disappears mid-development.
	 *
	 * Authoring tips: 20×20 viewBox, single-color silhouette, fill="#a7aaad"
	 * (default WP admin sidebar text colour) so it blends with the menu.
	 */
	private static function get_menu_icon(): string {
		$svg_path = STUDIOVAL_CLP_DIR . 'assets/icons/studioval.svg';

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

	public function render_page(): void {
		?>
		<div class="wrap">
			<div id="studioval-clp-settings"></div>
		</div>
		<?php
	}

	public function enqueue_scripts( string $hook ): void {
		if ( '' === $this->page_hook || $this->page_hook !== $hook ) {
			return;
		}

		$asset_file = STUDIOVAL_CLP_DIR . 'dist/settings.asset.php';
		$asset      = file_exists( $asset_file )
			? require $asset_file
			: [ 'dependencies' => [], 'version' => STUDIOVAL_CLP_VERSION ];

		wp_enqueue_media();

		wp_enqueue_script(
			'studioval-clp-settings',
			STUDIOVAL_CLP_URL . 'dist/settings.js',
			$asset['dependencies'],
			$asset['version'],
			true
		);

		wp_set_script_translations(
			'studioval-clp-settings',
			'studioval-clp',
			STUDIOVAL_CLP_DIR . 'languages'
		);

		wp_enqueue_style(
			'studioval-clp-settings',
			STUDIOVAL_CLP_URL . 'dist/settings.css',
			[ 'wp-components' ],
			$asset['version']
		);

		wp_localize_script(
			'studioval-clp-settings',
			'studiovalClpData',
			[
				'nonce'       => wp_create_nonce( 'wp_rest' ),
				'settings'    => get_option( self::OPTION_NAME, self::defaults() ),
				'defaults'    => self::defaults(),
				'loginUrl'    => wp_login_url(),
				'palette'     => $this->get_theme_palette(),
				'siteIconUrl' => get_site_icon_url(),
				'siteTitle'   => get_bloginfo( 'name' ),
				'siteTagline' => get_bloginfo( 'description' ),
			]
		);
	}

	private function get_theme_palette(): array {
		$raw = wp_get_global_settings( [ 'color', 'palette' ] );
		if ( ! is_array( $raw ) ) {
			return [];
		}

		$colors = [];
		foreach ( [ 'theme', 'default', 'custom' ] as $source ) {
			if ( empty( $raw[ $source ] ) || ! is_array( $raw[ $source ] ) ) {
				continue;
			}
			foreach ( $raw[ $source ] as $color ) {
				if ( ! empty( $color['color'] ) ) {
					$colors[] = [
						'name'  => $color['name'] ?? $color['slug'] ?? '',
						'color' => $color['color'],
					];
				}
			}
		}

		return $colors;
	}

	public function register_settings(): void {
		register_setting(
			'studioval_clp',
			self::OPTION_NAME,
			[
				'type'              => 'object',
				'default'           => self::defaults(),
				'sanitize_callback' => [ $this, 'sanitize' ],
				'show_in_rest'      => [
					'schema' => [
						'type'       => 'object',
						'properties' => [
							'layout'             => [ 'type' => 'string' ],
							'bgColor'            => [ 'type' => 'string' ],
							'formBgColor'        => [ 'type' => 'string' ],
							'textColor'          => [ 'type' => 'string' ],
							'buttonBgColor'      => [ 'type' => 'string' ],
							'buttonTextColor'    => [ 'type' => 'string' ],
							'linkColor'          => [ 'type' => 'string' ],
							'overlayColor'       => [ 'type' => 'string' ],
							'overlayOpacity'     => [ 'type' => 'number' ],
							'imageId'            => [ 'type' => 'integer' ],
							'imageUrl'           => [ 'type' => 'string' ],
							'logoId'             => [ 'type' => 'integer' ],
							'logoUrl'            => [ 'type' => 'string' ],
							'logoSource'         => [ 'type' => 'string' ],
							'customTitle'        => [ 'type' => 'string' ],
							'titleSource'        => [ 'type' => 'string' ],
							'buttonText'         => [ 'type' => 'string' ],
							'showForgotPassword' => [ 'type' => 'boolean' ],
							'showBackToHome'     => [ 'type' => 'boolean' ],
							'showRememberMe'     => [ 'type' => 'boolean' ],
							'genericErrors'      => [ 'type' => 'boolean' ],
							'redirectAdminUrl'   => [ 'type' => 'string' ],
							'redirectUserUrl'    => [ 'type' => 'string' ],
						],
					],
				],
			]
		);
	}

	public function sanitize( mixed $raw ): array {
		if ( ! is_array( $raw ) ) {
			return self::defaults();
		}

		$d                     = self::defaults();
		$allowed_layouts       = [ 'basic', 'image-left', 'image-right' ];
		$allowed_logo_sources  = [ 'custom', 'site-icon' ];
		$allowed_title_sources = [ 'custom', 'site' ];

		return [
			'layout'             => in_array( $raw['layout'] ?? '', $allowed_layouts, true ) ? $raw['layout'] : $d['layout'],
			'bgColor'            => sanitize_hex_color( $raw['bgColor'] ?? $d['bgColor'] ) ?? $d['bgColor'],
			'formBgColor'        => sanitize_hex_color( $raw['formBgColor'] ?? $d['formBgColor'] ) ?? $d['formBgColor'],
			'textColor'          => sanitize_hex_color( $raw['textColor'] ?? $d['textColor'] ) ?? $d['textColor'],
			'buttonBgColor'      => sanitize_hex_color( $raw['buttonBgColor'] ?? $d['buttonBgColor'] ) ?? $d['buttonBgColor'],
			'buttonTextColor'    => sanitize_hex_color( $raw['buttonTextColor'] ?? $d['buttonTextColor'] ) ?? $d['buttonTextColor'],
			'linkColor'          => sanitize_hex_color( $raw['linkColor'] ?? $d['linkColor'] ) ?? $d['linkColor'],
			'overlayColor'       => sanitize_hex_color( $raw['overlayColor'] ?? $d['overlayColor'] ) ?? $d['overlayColor'],
			'overlayOpacity'     => min( 1.0, max( 0.0, (float) ( $raw['overlayOpacity'] ?? $d['overlayOpacity'] ) ) ),
			'imageId'            => absint( $raw['imageId'] ?? 0 ),
			'imageUrl'           => esc_url_raw( $raw['imageUrl'] ?? '' ),
			'logoId'             => absint( $raw['logoId'] ?? 0 ),
			'logoUrl'            => esc_url_raw( $raw['logoUrl'] ?? '' ),
			'logoSource'         => in_array( $raw['logoSource'] ?? '', $allowed_logo_sources, true ) ? $raw['logoSource'] : $d['logoSource'],
			'customTitle'        => sanitize_text_field( $raw['customTitle'] ?? '' ),
			'titleSource'        => in_array( $raw['titleSource'] ?? '', $allowed_title_sources, true ) ? $raw['titleSource'] : $d['titleSource'],
			'buttonText'         => sanitize_text_field( $raw['buttonText'] ?? $d['buttonText'] ) ?: $d['buttonText'],
			'showForgotPassword' => (bool) ( $raw['showForgotPassword'] ?? $d['showForgotPassword'] ),
			'showBackToHome'     => (bool) ( $raw['showBackToHome'] ?? $d['showBackToHome'] ),
			'showRememberMe'     => (bool) ( $raw['showRememberMe'] ?? $d['showRememberMe'] ),
			'genericErrors'      => (bool) ( $raw['genericErrors'] ?? $d['genericErrors'] ),
			'redirectAdminUrl'   => esc_url_raw( $raw['redirectAdminUrl'] ?? '' ),
			'redirectUserUrl'    => esc_url_raw( $raw['redirectUserUrl'] ?? '' ),
		];
	}

	public static function defaults(): array {
		return [
			'layout'             => 'basic',
			'bgColor'            => '#f0f0f1',
			'formBgColor'        => '#ffffff',
			'textColor'          => '#1d2327',
			'buttonBgColor'      => '#2271b1',
			'buttonTextColor'    => '#ffffff',
			'linkColor'          => '#2271b1',
			'overlayColor'       => '#000000',
			'overlayOpacity'     => 0.4,
			'imageId'            => 0,
			'imageUrl'           => '',
			'logoId'             => 0,
			'logoUrl'            => '',
			'logoSource'         => 'custom',
			'customTitle'        => '',
			'titleSource'        => 'custom',
			'buttonText'         => 'Log In',
			'showForgotPassword' => true,
			'showBackToHome'     => true,
			'showRememberMe'     => true,
			'genericErrors'      => false,
			'redirectAdminUrl'   => '',
			'redirectUserUrl'    => '',
		];
	}
}
