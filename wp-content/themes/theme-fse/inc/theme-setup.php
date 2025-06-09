<?php

# Theme setup
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

# Add meta to <head>
function studio_add_head_meta()
{
    //echo '<meta name="google-site-verification" content="12345" />';
}
add_action('wp_head', 'studio_add_head_meta');
