<?php

/**
 * Allow every Block Editor features for administrators
 * 
 * @return WP_Theme_JSON
 */
function studio_grant_admin_block_editor_capabilities($theme_json)
{
    if (!current_user_can('edit_theme_options')) {
        return $theme_json;
    }

    $new_data = json_decode(
        file_get_contents(get_theme_file_path("admin.json")),
        true
    );

    return $theme_json->update_with($new_data);
}
add_filter('wp_theme_json_data_theme', 'studio_grant_admin_block_editor_capabilities');
