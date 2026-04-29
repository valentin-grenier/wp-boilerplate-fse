<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

class StudioVal_CLP_Login_Customizer {

	private array $settings;

	public function init(): void {
		$defaults       = StudioVal_CLP_Settings_Page::defaults();
		$saved          = get_option( StudioVal_CLP_Settings_Page::OPTION_NAME, [] );
		$this->settings = is_array( $saved ) ? array_merge( $defaults, $saved ) : $defaults;

		add_action( 'login_enqueue_scripts', [ $this, 'enqueue_styles' ] );
		add_action( 'login_head', [ $this, 'output_dynamic_styles' ] );
		add_filter( 'login_body_class', [ $this, 'add_body_classes' ] );
		add_filter( 'login_headerurl', [ $this, 'logo_url' ] );
		add_filter( 'login_headertext', [ $this, 'logo_text' ] );
		add_action( 'login_form', [ $this, 'maybe_filter_button_text' ] );
		add_filter( 'wp_login_errors', [ $this, 'maybe_generic_errors' ], 10, 2 );
		add_filter( 'login_redirect', [ $this, 'custom_redirect' ], 10, 3 );
	}

	public function enqueue_styles(): void {
		if ( ! file_exists( STUDIOVAL_CLP_DIR . 'dist/login.css' ) ) {
			return;
		}

		wp_enqueue_style(
			'studioval-clp-login',
			STUDIOVAL_CLP_URL . 'dist/login.css',
			[],
			STUDIOVAL_CLP_VERSION
		);
	}

	public function add_body_classes( array $classes ): array {
		$s = $this->settings;

		$classes[] = 'clp-layout-' . $s['layout'];

		if ( ! $s['showForgotPassword'] ) {
			$classes[] = 'clp-hide-forgot-password';
		}
		if ( ! $s['showBackToHome'] ) {
			$classes[] = 'clp-hide-back-to-home';
		}
		if ( ! $s['showRememberMe'] ) {
			$classes[] = 'clp-hide-remember-me';
		}

		return $classes;
	}

	public function output_dynamic_styles(): void {
		$s = $this->settings;

		$bg_color        = esc_attr( $s['bgColor'] );
		$form_bg_color   = esc_attr( $s['formBgColor'] );
		$text_color      = esc_attr( $s['textColor'] );
		$button_bg       = esc_attr( $s['buttonBgColor'] );
		$button_text     = esc_attr( $s['buttonTextColor'] );
		$link_color      = esc_attr( $s['linkColor'] );
		$overlay_rgba    = $this->hex_to_rgba( $s['overlayColor'], (float) $s['overlayOpacity'] );
		$image_url       = esc_url( $s['imageUrl'] );
		$logo_src        = 'site-icon' === ( $s['logoSource'] ?? 'custom' )
			? get_site_icon_url()
			: $s['logoUrl'];
		$logo_url        = esc_url( $logo_src );
		$layout          = esc_attr( $s['layout'] );
		$has_image       = ! empty( $s['imageUrl'] );

		?>
		<style id="studioval-clp-dynamic">
			body.login { background-color: <?php echo $bg_color; ?>; color: <?php echo $text_color; ?>; }
			body.login #loginform,
			body.login #lostpasswordform,
			body.login #resetpassform { background: <?php echo $form_bg_color; ?>; }
			body.login label { color: <?php echo $text_color; ?>; }
			body.login .wp-pwd button.button-link { color: <?php echo $text_color; ?>; }
			body.login a { color: <?php echo $link_color; ?>; }
			body.login a:hover { color: <?php echo $link_color; ?>; filter: brightness(1.15); }
			body.login #wp-submit,
			body.login .button-primary {
				background: <?php echo $button_bg; ?>;
				border-color: <?php echo $button_bg; ?>;
				color: <?php echo $button_text; ?>;
				box-shadow: none;
				text-shadow: none;
			}
			body.login #wp-submit:hover,
			body.login .button-primary:hover {
				background: <?php echo $button_bg; ?>;
				filter: brightness(0.9);
				color: <?php echo $button_text; ?>;
			}
			<?php if ( $logo_url ) : ?>
			body.login h1 a {
				background-image: url('<?php echo $logo_url; ?>');
				background-size: contain;
				width: 200px;
				height: 80px;
			}
			<?php endif; ?>
			<?php if ( $has_image && $image_url ) : ?>
			body.login.clp-layout-<?php echo $layout; ?>::before {
				background-image: url('<?php echo $image_url; ?>');
			}
			body.login.clp-layout-<?php echo $layout; ?>::after {
				background-color: <?php echo $overlay_rgba; ?>;
			}
			<?php endif; ?>
		</style>
		<?php
	}

	public function logo_url(): string {
		return home_url( '/' );
	}

	public function logo_text(): string {
		$source = $this->settings['titleSource'] ?? 'custom';

		if ( 'site' === $source ) {
			return esc_html( get_bloginfo( 'name' ) );
		}

		$title = $this->settings['customTitle'] ?? '';
		return esc_html( $title ?: get_bloginfo( 'name' ) );
	}

	public function maybe_filter_button_text(): void {
		$button_text = $this->settings['buttonText'] ?? 'Log In';
		if ( $button_text && 'Log In' !== $button_text ) {
			add_filter( 'gettext', [ $this, 'filter_button_text' ], 20, 3 );
		}
	}

	public function filter_button_text( string $translation, string $text, string $domain ): string {
		if ( 'default' === $domain && 'Log In' === $text ) {
			return sanitize_text_field( $this->settings['buttonText'] );
		}
		return $translation;
	}

	public function maybe_generic_errors( \WP_Error $errors ): \WP_Error {
		if ( ! ( $this->settings['genericErrors'] ?? false ) ) {
			return $errors;
		}

		$auth_codes  = [ 'invalid_username', 'invalid_email', 'incorrect_password', 'invalidcombo' ];
		$error_codes = $errors->get_error_codes();
		$has_auth_error = (bool) array_intersect( $auth_codes, $error_codes );

		if ( ! $has_auth_error ) {
			return $errors;
		}

		$new_errors = new \WP_Error();

		foreach ( $error_codes as $code ) {
			if ( ! in_array( $code, $auth_codes, true ) ) {
				$new_errors->add( $code, $errors->get_error_message( $code ) );
			}
		}

		$new_errors->add(
			'authentication_failed',
			__( '<strong>Error:</strong> The username or password you entered is incorrect.', 'studioval-clp' )
		);

		return $new_errors;
	}

	public function custom_redirect( string $redirect_to, string $requested_redirect_to, \WP_User|\WP_Error $user ): string {
		if ( is_wp_error( $user ) ) {
			return $redirect_to;
		}

		if ( $user->has_cap( 'manage_options' ) ) {
			$url = $this->settings['redirectAdminUrl'] ?? '';
			return $url ?: $redirect_to;
		}

		$url = $this->settings['redirectUserUrl'] ?? '';
		return $url ?: $redirect_to;
	}

	private function hex_to_rgba( string $hex, float $opacity ): string {
		$hex = ltrim( $hex, '#' );

		if ( 3 === strlen( $hex ) ) {
			$hex = $hex[0] . $hex[0] . $hex[1] . $hex[1] . $hex[2] . $hex[2];
		}

		if ( 6 !== strlen( $hex ) ) {
			return "rgba(0,0,0,{$opacity})";
		}

		$r = hexdec( substr( $hex, 0, 2 ) );
		$g = hexdec( substr( $hex, 2, 2 ) );
		$b = hexdec( substr( $hex, 4, 2 ) );

		return "rgba({$r},{$g},{$b},{$opacity})";
	}
}
