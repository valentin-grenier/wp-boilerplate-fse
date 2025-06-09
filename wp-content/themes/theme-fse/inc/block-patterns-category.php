<?php

/**
 * Add custom category for patterns in the Block Editor
 * 
 * @return void
 */
function studio_register_patterns_categories()
{
    register_block_pattern_category(
        "Studio Val",
        array(
            'label' => __('Studio Val', 'studio-val'),
            'icon'  => 'star-filled',
        )
    );
}
add_filter('init', 'studio_register_patterns_categories');
