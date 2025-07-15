<?php

/**
 * Set custom block bindings for meta data
 * 
 * @return void
 */
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
add_action('init', 'studio_register_meta');

function studio_callback_meta_slug($source_args, $block_instance, $attribute_name)
{
    return '';
}
