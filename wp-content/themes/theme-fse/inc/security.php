<?php

/**
 * Block XML-RPC requests for security
 */
add_filter('xmlrpc_enabled', '__return_false');

/**
 * Hide WordPress version in source code and feeds.
 */
remove_action('wp_head', 'wp_generator');
add_filter('the_generator', '__return_empty_string');

/**
 * Disable file editing in the admin.
 */
if (is_admin() && !defined('DISALLOW_FILE_EDIT')) {
    define('DISALLOW_FILE_EDIT', true);
}

/**
 * Disable login errors to avoid user enumeration.
 *
 * @param string $error The default login error message.
 * @return string
 */
function studio_hide_login_errors($error)
{
    return __('Login failed. Please try again.', 'studio-theme');
}
add_filter('login_errors', 'studio_hide_login_errors');

/**
 * Disable directory browsing via .htaccess fallback.
 * 
 * @return void
 */
function studio_disable_directory_browsing()
{
    $htaccess = ABSPATH . '.htaccess';

    if (is_writable($htaccess) && strpos(file_get_contents($htaccess), 'Options -Indexes') === false) {
        file_put_contents($htaccess, "Options -Indexes\n", FILE_APPEND);
    }
}
add_action('init', 'studio_disable_directory_browsing');

/**
 * Disable author archive scans
 * 
 * @return void
 */
function studio_disable_author_archive_scans()
{
    if (is_author() && !is_user_logged_in()) {
        wp_redirect(home_url());
        exit;
    }
}
add_action('template_redirect', 'studio_disable_author_archive_scans');
