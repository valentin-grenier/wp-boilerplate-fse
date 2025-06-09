<?php

# Theme assets
function studio_theme_assets()
{
    # Styles
    wp_enqueue_style("studio-theme-styles", get_template_directory_uri() . "/assets/css/main.css", [], wp_get_theme()->get("Version"));

    # Scripts
    wp_enqueue_script("studio-theme-scripts", get_template_directory_uri() . "/assets/js/app.js", [], wp_get_theme()->get("Version"), true);

    # Disable CSS for some blocks
    # wp_dequeue_style("wp-block-columns");
}
add_action('wp_enqueue_scripts', 'studio_theme_assets');
