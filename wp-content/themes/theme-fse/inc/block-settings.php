<?php

/**
 * Remove block style variations in the editor
 *
 * @return void
 */
function studio_remove_block_style_variations()
{
    wp_enqueue_script(
        "studio-script-unregister-style-variations",
        get_template_directory_uri() . "/assets/js/editor/unregister-style-variations.js",
        ["wp-blocks", "wp-dom-ready", "wp-edit-post"],
        "1.0"
    );
}
add_action('enqueue_block_editor_assets', 'studio_remove_block_style_variations');

/**
 * Remove blocks from the Block Editor
 * 
 * @return void
 */
function studio_unregister_comment_blocks_script()
{
    wp_enqueue_script(
        'studio-unregister-comment-blocks',
        get_template_directory_uri() . '/assets/js/editor/unregister-blocks.js',
        ['wp-blocks', 'wp-dom-ready', 'wp-edit-post'],
        wp_get_theme()->get('Version'),
        true
    );
}
add_action('enqueue_block_editor_assets', 'studio_unregister_comment_blocks_script');

/**
 * Remove heading levels from the Block Editor
 * 
 * @return array
 */
function studio_remove_heading_levels($args, $block_type)
{
    if ($block_type !== 'core/heading') {
        return $args;
    }

    // Allow only levels 1, 2, and 3
    $args['attributes']['levelOptions']['default'] = array(1, 2, 3);

    return $args;
}
add_action('register_block_type_args', 'studio_remove_heading_levels', 10, 2);
