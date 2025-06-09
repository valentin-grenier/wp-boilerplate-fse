<?php

# Remove block styles variations
function studio_remove_block_style_variations()
{
    wp_enqueue_script(
        "studio-script-unregister-style-variations",
        get_template_directory_uri() . "/assets/js/unregister-style-variations.js",
        ["wp-blocks", "wp-dom-ready", "wp-edit-post"],
        "1.0"
    );
}
add_action('enqueue_block_editor_assets', 'studio_remove_block_style_variations');
