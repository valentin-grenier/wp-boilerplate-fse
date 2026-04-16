<?php

if ( ! defined( 'ABSPATH' ) ) {
    exit; // Exit if accessed directly
}

/**
 * Register theme options menu page
 */
function studio_theme_options_menu()
{
    add_menu_page(
        __('Options du thème', 'theme-name'),           // Page title
        __('Options', 'theme-name'),           // Menu title
        'manage_options',                         // Capability
        'studio-theme-options',                  // Menu slug
        'studio_theme_options_page',             // Callback function
        'dashicons-admin-generic',                // Icon
        80                                        // Position
    );
}
add_action('admin_menu', 'studio_theme_options_menu');

/**
 * Register theme options settings
 */
function studio_theme_options_register()
{
    register_setting('studio_theme_options', 'sarbacane_api_key', [
        'type'              => 'string',
        'sanitize_callback' => 'sanitize_text_field',
        'default'           => '',
        'show_in_rest'      => true,
    ]);
}
add_action('init', 'studio_theme_options_register');

/**
 * Enqueue admin script on the theme options page
 */
function studio_theme_options_assets( $hook_suffix ) {
    if ( $hook_suffix !== 'toplevel_page_studio-theme-options' ) {
        return;
    }

    wp_enqueue_script(
        'studio-admin-options',
        get_template_directory_uri() . '/dist/js/admin.bundle.js',
        [ 'wp-element', 'wp-i18n', 'wp-api-fetch', 'wp-components' ],
        filemtime( get_template_directory() . '/dist/js/admin.bundle.js' ),
        true
    );

    wp_enqueue_style(
        'studio-admin-options',
        get_template_directory_uri() . '/dist/css/admin.css',
        [ 'wp-components' ],
        filemtime( get_template_directory() . '/dist/css/admin.css' )
    );
}
add_action( 'admin_enqueue_scripts', 'studio_theme_options_assets' );

/**
 * Theme options page HTML
 */
function studio_theme_options_page()
{
    if (!current_user_can('manage_options')) {
        return;
    }

    require get_template_directory() . '/views/admin/theme-options-page.php';
}

