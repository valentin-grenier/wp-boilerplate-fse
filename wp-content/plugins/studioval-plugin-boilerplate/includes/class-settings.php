<?php
/**
 * Settings — registers the option, REST schema, and sanitization callback.
 *
 * The single source of truth for: option name, defaults, allowed values,
 * sanitization. Other classes (admin page, frontend) call the static helpers
 * `defaults()` and `get()` to read state.
 *
 * @package Studioval\Plugin_Boilerplate
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

final class Studioval_Plugin_Boilerplate_Settings {

	use Studioval_Plugin_Boilerplate_Singleton;

	public const OPTION_NAME  = 'studioval_plugin_boilerplate_settings';
	public const OPTION_GROUP = 'studioval_plugin_boilerplate';

	/**
	 * Register the setting on `init` so it is available to both admin and REST.
	 */
	private function __construct() {
		add_action( 'init', array( $this, 'register_setting' ) );
	}

	/**
	 * Register the option with REST exposure.
	 *
	 * `show_in_rest` is what makes the WordPress core `/wp/v2/settings` endpoint
	 * read and write our option — no custom REST controller needed.
	 */
	public function register_setting(): void {
		register_setting(
			self::OPTION_GROUP,
			self::OPTION_NAME,
			array(
				'type'              => 'object',
				'default'           => self::defaults(),
				'sanitize_callback' => array( $this, 'sanitize' ),
				'show_in_rest'      => array(
					'schema' => array(
						'type'       => 'object',
						'properties' => array(
							'enabled'     => array( 'type' => 'boolean' ),
							'message'     => array( 'type' => 'string' ),
							'position'    => array( 'type' => 'string' ),
							'bgColor'     => array( 'type' => 'string' ),
							'textColor'   => array( 'type' => 'string' ),
							'dismissible' => array( 'type' => 'boolean' ),
						),
					),
				),
			)
		);
	}

	/**
	 * Default values — used by REST schema, sanitization fallback, and the JS reset action.
	 *
	 * @return array<string, mixed>
	 */
	public static function defaults(): array {
		return array(
			'enabled'     => false,
			'message'     => __( 'Hello from the plugin boilerplate!', 'studioval-plugin-boilerplate' ),
			'position'    => 'top',
			'bgColor'     => '#1d2327',
			'textColor'   => '#ffffff',
			'dismissible' => true,
		);
	}

	/**
	 * Read the saved option, merged with defaults so missing keys don't bite us downstream.
	 *
	 * @return array<string, mixed>
	 */
	public static function get(): array {
		$saved = get_option( self::OPTION_NAME, array() );
		if ( ! is_array( $saved ) ) {
			return self::defaults();
		}
		return array_merge( self::defaults(), $saved );
	}

	/**
	 * Sanitize input from the REST endpoint before it hits the database.
	 *
	 * @param mixed $raw Untrusted input from the API.
	 * @return array<string, mixed>
	 */
	public function sanitize( mixed $raw ): array {
		if ( ! is_array( $raw ) ) {
			return self::defaults();
		}

		$d                 = self::defaults();
		$allowed_positions = array( 'top', 'bottom' );

		return array(
			'enabled'     => (bool) ( $raw['enabled'] ?? $d['enabled'] ),
			'message'     => sanitize_text_field( (string) ( $raw['message'] ?? $d['message'] ) ),
			'position'    => in_array( $raw['position'] ?? '', $allowed_positions, true )
				? $raw['position']
				: $d['position'],
			'bgColor'     => sanitize_hex_color( (string) ( $raw['bgColor'] ?? '' ) ) ?? $d['bgColor'],
			'textColor'   => sanitize_hex_color( (string) ( $raw['textColor'] ?? '' ) ) ?? $d['textColor'],
			'dismissible' => (bool) ( $raw['dismissible'] ?? $d['dismissible'] ),
		);
	}
}
