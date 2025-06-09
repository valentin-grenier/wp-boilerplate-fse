<?php

/**
 * Remove dashboard widgets
 * 
 * @return void
 */
function studio_remove_dashboard_widgets()
{
    // Core WordPress widgets
    // remove_meta_box('dashboard_activity',       'dashboard', 'normal'); // Activity
    remove_meta_box('dashboard_right_now',      'dashboard', 'normal'); // At a Glance
    remove_meta_box('dashboard_quick_press',    'dashboard', 'side');   // Quick Draft
    // remove_meta_box('dashboard_primary',        'dashboard', 'side');   // WordPress Events and News

    // Plugin-related widgets (if installed)
    remove_meta_box('yoast_db_widget',          'dashboard', 'normal'); // Yoast SEO
    remove_meta_box('rg_forms_dashboard',       'dashboard', 'normal'); // Gravity Forms
    remove_meta_box('wpe_dify_news_feed',       'dashboard', 'normal'); // WP Engine
    // remove_meta_box('dashboard_site_health',    'dashboard', 'normal'); // Site Health (WP 5.2+)
    // remove_meta_box('dashboard_php_nag',        'dashboard', 'normal'); // PHP Update Required
    remove_meta_box('jetpack_summary_widget',   'dashboard', 'normal'); // Jetpack
    remove_meta_box('woocommerce_dashboard_status', 'dashboard', 'normal'); // WooCommerce
    // remove_meta_box('dashboard_browser_nag',    'dashboard', 'normal'); // Browser outdated notice
}
add_action('wp_dashboard_setup', 'studio_remove_dashboard_widgets');
