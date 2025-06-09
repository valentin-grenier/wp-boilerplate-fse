<?php

/**
 * Remove heading levels from the Block Editor
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
