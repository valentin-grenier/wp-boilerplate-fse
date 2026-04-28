<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

class StudioVal_CLP_Settings_Page {

	const OPTION_NAME = 'studioval_clp_settings';

	public function init(): void {
		add_action( 'admin_menu', [ $this, 'add_menu_page' ] );
		add_action( 'admin_enqueue_scripts', [ $this, 'enqueue_scripts' ] );
		add_action( 'rest_api_init', [ $this, 'register_settings' ] );
	}

	public function add_menu_page(): void {
		add_options_page(
			__( 'Custom login', 'studioval-clp' ),
			__( 'Custom login', 'studioval-clp' ),
			'manage_options',
			'studioval-custom-login',
			[ $this, 'render_page' ]
		);
	}

	public function render_page(): void {
		?>
		<div class="wrap">
			<div id="studioval-clp-settings"></div>
		</div>
		<?php
	}

	public function enqueue_scripts( string $hook ): void {
		if ( 'settings_page_studioval-custom-login' !== $hook ) {
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
				'nonce'    => wp_create_nonce( 'wp_rest' ),
				'settings' => get_option( self::OPTION_NAME, self::defaults() ),
				'loginUrl' => wp_login_url(),
				'palette'  => $this->get_theme_palette(),
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
							'customTitle'        => [ 'type' => 'string' ],
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

		$d               = self::defaults();
		$allowed_layouts = [ 'basic', 'image-left', 'image-right' ];

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
			'customTitle'        => sanitize_text_field( $raw['customTitle'] ?? '' ),
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
			'customTitle'        => '',
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
