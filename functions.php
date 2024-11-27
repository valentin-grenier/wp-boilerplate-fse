<?php

// == Theme Setup ==
function studio_theme_setup()
{
    # Remove accents from file names
    add_filter("sanitize_file_name", "remove_accents");

    # Remove pattern directory et blocks suggestions
    remove_action('enqueue_block_editor_assets', 'wp_enqueue_editor_block_directory_assets');
    remove_theme_support("core-block-patterns");

    # Remove WP version
    remove_action('wp_head', 'wp_generator');
}

add_action("after_setup_theme", "studio_theme_setup");

// == Theme assets ==
function studio_theme_assets()
{
    # Styles
    wp_enqueue_style("studio-style", get_template_directory_uri() . "/assets/css/main.css", [], wp_get_theme()->get("Version"));

    # Scripts
    wp_enqueue_script("studio-script", get_template_directory_uri() . "/assets/js/app.js", [], wp_get_theme()->get("Version"), true);

    # Disable CSS for some blocks
    # wp_dequeue_style("wp-block-columns");
}
add_action('wp_enqueue_scripts', 'studio_theme_assets');

// == Remove block styles variations ==
function studio_remove_block_style_variations()
{
    wp_enqueue_script(
        "unregister-style-variations",
        get_template_directory_uri() . "/assets/js/unregister-style-variations.js",
        ["wp-blocks", "wp-dom-ready", "wp-edit-post"],
        "1.0"
    );
}
add_action('enqueue_block_editor_assets', 'studio_remove_block_style_variations');
