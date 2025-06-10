<?php

/**
 * Enqueue frontend assets.
 *
 * @return void
 */
function studio_theme_assets()
{
    // Styles
    wp_enqueue_style(
        'studio-theme-styles',
        get_template_directory_uri() . '/assets/css/main.css',
        [],
        wp_get_theme()->get('Version')
    );

    // Enqueue all JS files in /assets/js/
    $js_dir = get_template_directory() . '/assets/js/public/';
    $js_uri = get_template_directory_uri() . '/assets/js/public/';

    foreach (glob($js_dir . '*.js') as $index => $file) {
        $handle = 'studio-js-' . basename($file, '.js');
        $uri    = $js_uri . basename($file);

        wp_enqueue_script(
            $handle,
            $uri,
            [],
            wp_get_theme()->get('Version'),
            true
        );
    }

    // Remove dashicons for non-logged-in users.
    if (! is_user_logged_in()) {
        wp_deregister_style('dashicons');
    }

    // Optional: disable block CSS for performance.
    // wp_dequeue_style( 'wp-block-columns' );
}
add_action('wp_enqueue_scripts', 'studio_theme_assets');

/**
 * Autoload Composer vendor files if available.
 *
 * @return void
 */
function studio_theme_autoload_vendor()
{
    if (!defined('ABSPATH')) return;

    $vendor_dir = ABSPATH . 'vendor/autoload.php';

    if (file_exists($vendor_dir)) {
        require_once $vendor_dir;
    }
}
add_action('after_setup_theme', 'studio_theme_autoload_vendor');

/**
 * Load only the necessary block CSS per page (since WP 6.1).
 */
add_filter('should_load_separate_core_block_assets', '__return_true');
