<?php

/**
 * Admin view: Theme Options Page
 * Loaded by studio_theme_options_page() in inc/theme-option.php
 */

if ( ! defined( 'ABSPATH' ) ) {
    exit; // Exit if accessed directly
}

if (!current_user_can('manage_options')) {
    return;
}
?>

<div class="wp-admin-theme-name-theme-options-page wrap">
    <h1 class="wp-admin-theme-name-theme-options-page__title"><?php esc_html_e('Options du thème', 'theme-name'); ?></h1>
    <div id="wp-admin-theme-name-theme-options-page__root"></div>
</div>
