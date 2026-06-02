<?php
/**
 * Singleton trait — used by every public class in the plugin.
 *
 * Each consumer class declares `private function __construct()` to prevent
 * external instantiation, registers its hooks inside that constructor, then
 * is bootstrapped via `ClassName::instance()`. The trait stores one instance
 * per consuming class (PHP traits are merged at compile time, so `self`
 * resolves to the using class).
 *
 * @package Studioval\Plugin_Boilerplate
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

trait Theme_Fse_Plugin_Boilerplate_Singleton {

	/**
	 * Single instance, created on first call to `instance()`.
	 *
	 * @var self|null
	 */
	private static ?self $instance = null;

	/**
	 * Return the single instance, creating it on first call.
	 */
	final public static function instance(): self {
		if ( null === self::$instance ) {
			self::$instance = new self();
		}
		return self::$instance;
	}

	/**
	 * Singletons cannot be cloned.
	 */
	private function __clone() {}

	/**
	 * Singletons cannot be unserialized.
	 *
	 * @throws \LogicException Always.
	 */
	public function __wakeup(): void {
		throw new \LogicException( 'Cannot unserialize a singleton.' );
	}
}
