<?php

/**
 * Set up theme defaults and supports.
 *
 * @return void
 */
function studio_theme_setup()
{
    // Theme supports.
    add_theme_support('title-tag');
    add_theme_support('post-thumbnails');
    add_theme_support(
        'html5',
        [
            'search-form',
            'comment-form',
            'comment-list',
            'gallery',
            'caption',
            'script',
            'style',
        ]
    );
    add_theme_support('responsive-embeds');

    // Optional: Editor styles (uncomment if needed).
    // add_theme_support( 'editor-styles' );
    // add_editor_style( 'assets/css/editor.css' );

    // Remove core block patterns and block directory suggestions.
    remove_action('enqueue_block_editor_assets', 'wp_enqueue_editor_block_directory_assets');
    remove_theme_support('core-block-patterns');

    // Clean up <head>.
    remove_action('wp_head', 'wp_generator');
    remove_action('wp_head', 'wlwmanifest_link');
    remove_action('wp_head', 'rsd_link');
}
add_action('after_setup_theme', 'studio_theme_setup');

/**
 * Add custom <meta> tags to the head.
 *
 * @return void
 */
function studio_add_head_meta()
{
    // echo '<meta name="google-site-verification" content="12345" />';
}
add_action('wp_head', 'studio_add_head_meta');

/**
 * Sanitize filenames by removing accents.
 */
add_filter('sanitize_file_name', 'remove_accents');

/**
 * Remove default dashboard widgets.
 *
 * @return void
 */
function studio_remove_dashboard_widgets()
{
    // Core widgets.
    remove_meta_box('dashboard_right_now', 'dashboard', 'normal');
    remove_meta_box('dashboard_quick_press', 'dashboard', 'side');

    // Plugin widgets (if installed).
    remove_meta_box('yoast_db_widget', 'dashboard', 'normal');
    remove_meta_box('rg_forms_dashboard', 'dashboard', 'normal');
    remove_meta_box('wpe_dify_news_feed', 'dashboard', 'normal');
    remove_meta_box('jetpack_summary_widget', 'dashboard', 'normal');
    remove_meta_box('woocommerce_dashboard_status', 'dashboard', 'normal');
}
add_action('wp_dashboard_setup', 'studio_remove_dashboard_widgets');
