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

/**
 * Customize the WordPress admin logo
 * 
 * @return void
 */
function studio_custom_admin_logo()
{
    $icon_url = get_stylesheet_directory_uri() . '/dist/theme/admin-logo.svg';

    echo '<style type="text/css">
        /* WordPress Admin Bar Logo */
        #wpadminbar #wp-admin-bar-wp-logo {
            width: 80px;
        }

        #wpadminbar #wp-admin-bar-wp-logo > .ab-item .ab-icon {
            margin-right: 0 !important;
            width: 100%;
        }

        #wpadminbar #wp-admin-bar-wp-logo > .ab-item .ab-icon:before {
            background-image: url(' . $icon_url . ') !important;
            background-size: 67px 20px !important;
            background-repeat: no-repeat !important;
            background-position: center !important;
            content: "" !important;
            width: 67px !important;
            height: 20px !important;
            display: inline-block !important;
        }
        
        /* Additional fallback for different WordPress versions */
        #wpadminbar #wp-admin-bar-wp-logo .ab-icon {
            background-image: url(' . $icon_url . ') !important;
            background-size: 20px !important;
            background-repeat: no-repeat !important;
            background-position: center !important;
            width: 20px !important;
            height: 20px !important;
            display: inline-block !important;
        }
        
        #wpadminbar #wp-admin-bar-wp-logo .ab-icon:before {
            content: "" !important;
        }
        
        /* Admin dashboard logo (WordPress 5.4+) */
        .wp-admin .wp-admin-bar-wp-logo > .ab-item .ab-icon:before {
            background-image: url(' . $icon_url . ') !important;
            background-size: 20px 20px !important;
            background-repeat: no-repeat !important;
            background-position: center !important;
            content: "" !important;
            width: 20px !important;
            height: 20px !important;
            display: inline-block !important;
        }
        
        /* Custom submenu styling */
        #wpadminbar .ab-top-secondary .menupop .ab-sub-wrapper {
            min-width: 150px;
        }
    </style>';
}
add_action('admin_head', 'studio_custom_admin_logo');
add_action('login_head', 'studio_custom_admin_logo');
add_action('wp_head', 'studio_custom_admin_logo');

/**
 * Customize WordPress logo submenu in admin bar
 * 
 * @return void
 */
function studio_custom_admin_bar_menu()
{
    global $wp_admin_bar;

    if (!is_admin_bar_showing()) {
        return;
    }

    // Remove some default WordPress submenu items (keep wp-logo-external for "Get Involved")
    $wp_admin_bar->remove_menu('about');
    $wp_admin_bar->remove_menu('wporg');
    $wp_admin_bar->remove_menu('documentation');
    $wp_admin_bar->remove_menu('support-forums');
    $wp_admin_bar->remove_menu('feedback');
    $wp_admin_bar->remove_menu('learn');

    // Add custom submenu items under "Get Involved"
    $wp_admin_bar->add_menu(array(
        'parent' => 'wp-logo-external',
        'id'     => 'studio-val',
        'title'  => 'Studio Val',
        'href'   => 'https://studio-val.fr',
        'meta'   => array(
            'target' => '_blank',
            'title'  => 'Voir le site de Studio Val',
        ),
    ));

    $wp_admin_bar->add_menu(array(
        'parent' => 'wp-logo-external',
        'id'     => 'contact-support',
        'title'  => "J'ai un problème",
        'href'   => 'mailto:valentin@studio-val.fr?subject=Demande de support - ' . get_bloginfo('name'),
        'meta'   => array(
            'target' => '_blank',
            'title'  => 'Contacter le support',
        ),
    ));

    $wp_admin_bar->add_menu(array(
        'parent' => 'wp-logo-external',
        'id'     => 'meeting',
        'title'  => "Prendre rendez-vous",
        'href'   => 'https://app.lemcal.com/@valentin-grenier',
        'meta'   => array(
            'target' => '_blank',
            'title'  => 'Prendre rendez-vous',
        ),
    ));
}
add_action('wp_before_admin_bar_render', 'studio_custom_admin_bar_menu');
