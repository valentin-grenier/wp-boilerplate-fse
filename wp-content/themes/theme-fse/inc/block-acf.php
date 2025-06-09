<?php

/**
 * Register custom ACF blocks for the Block Editor
 */

function studio_register_acf_blocks()
{
    $block_json_files = glob(get_template_directory() . '/blocks/*/block.json');

    foreach ($block_json_files as $block_json_file) {
        register_block_type($block_json_file);
    };
}
add_action('acf/init', 'studio_register_acf_blocks');
