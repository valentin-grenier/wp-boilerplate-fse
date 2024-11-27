<?php

// == Set custom meta bindings ==
add_action('init', 'studio_register_meta');
function studio_register_meta()
{
    register_block_bindings_source(
        'namespace/slug',
        array(
            'label' => '',
            'get_value_callback' => 'studio_callback_meta_slug'
        )
    );
}

function studio_callback_meta_slug($source_args, $block_attributes, $block_content, $post_id)
{
    return '';
}
