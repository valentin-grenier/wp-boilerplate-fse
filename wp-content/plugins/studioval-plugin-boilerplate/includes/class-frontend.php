<?php
/**
 * Frontend — renders the demo banner and enqueues the vanilla JS/SCSS bundle.
 *
 * Replace the banner with whatever your real plugin needs to do on the public
 * site. The pattern (option-driven render + escaped output + wp_localize_script
 * for JS config) is the part worth keeping.
 *
 * @package Studioval\Plugin_Boilerplate
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

final class Studioval_Plugin_Boilerplate_Frontend {

	use Studioval_Plugin_Boilerplate_Singleton;

	private function __construct() {
		add_action( 'wp_enqueue_scripts', array( $this, 'enqueue_assets' ) );
		add_action( 'wp_footer', array( $this, 'render_banner' ) );
	}

	/**
	 * Skip everything (asset and markup) when the banner is disabled.
	 */
	private function is_enabled(): bool {
		$settings = Studioval_Plugin_Boilerplate_Settings::get();
		return ! empty( $settings['enabled'] ) && ! empty( $settings['message'] );
	}

	public function enqueue_assets(): void {
		if ( ! $this->is_enabled() ) {
			return;
		}

		$asset_file = dirname( __DIR__ ) . '/dist/frontend.asset.php';
		$asset      = file_exists( $asset_file )
			? require $asset_file
			: array(
				'dependencies' => array(),
				'version'      => STUDIOVAL_PLUGIN_BOILERPLATE_VERSION,
			);

		wp_enqueue_script(
			'studioval-plugin-boilerplate-frontend',
			STUDIOVAL_PLUGIN_BOILERPLATE_URL . 'dist/frontend.js',
			$asset['dependencies'],
			$asset['version'],
			true
		);

		wp_enqueue_style(
			'studioval-plugin-boilerplate-frontend',
			STUDIOVAL_PLUGIN_BOILERPLATE_URL . 'dist/frontend.css',
			array(),
			$asset['version']
		);
	}

	/**
	 * Output the banner markup. Every dynamic value is escaped at output —
	 * sanitization happens on the way *in* (Settings::sanitize), escaping on
	 * the way *out*.
	 */
	public function render_banner(): void {
		if ( ! $this->is_enabled() ) {
			return;
		}

		$settings = Studioval_Plugin_Boilerplate_Settings::get();

		$message     = (string) $settings['message'];
		$position    = (string) $settings['position'];
		$bg_color    = (string) $settings['bgColor'];
		$text_color  = (string) $settings['textColor'];
		$dismissible = (bool) $settings['dismissible'];

		$style = sprintf(
			'background-color: %s; color: %s;',
			esc_attr( $bg_color ),
			esc_attr( $text_color )
		);

		$classes = array( 'svpb-banner', 'svpb-banner--' . sanitize_html_class( $position ) );
		if ( $dismissible ) {
			$classes[] = 'svpb-banner--dismissible';
		}

		printf(
			'<div class="%1$s" style="%2$s" role="status">',
			esc_attr( implode( ' ', $classes ) ),
			esc_attr( $style )
		);

		echo '<p class="svpb-banner__message">' . esc_html( $message ) . '</p>';

		if ( $dismissible ) {
			printf(
				'<button type="button" class="svpb-banner__close" aria-label="%s">&times;</button>',
				esc_attr__( 'Dismiss banner', 'studioval-plugin-boilerplate' )
			);
		}

		echo '</div>';
	}
}
