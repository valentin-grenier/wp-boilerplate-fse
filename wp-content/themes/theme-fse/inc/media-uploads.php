<?php

/**
 * Allow SVG images to be uploaded securely
 * 
 * @return array
 */
function studio_allow_svg_uploads($mimes)
{
    if (user_can_('manage_options')) {
        $mimes['svg'] = 'image/svg+xml';
    }

    return $mimes;
}
add_filter('upload_mimes', 'studio_allow_svg_uploads');

/**
 * Sanitize SVG files by stripping scripts/styles/entities.
 *
 * @param string $file Path to the uploaded file.
 * @return void
 */
function studio_sanitize_svg_file($file)
{
    if (
        pathinfo($file, PATHINFO_EXTENSION) === 'svg' &&
        current_user_can('manage_options')
    ) {
        $svg = file_get_contents($file);

        // Remove script/style/foreignObject tags
        $svg = preg_replace('/<(script|style|foreignObject).*?<\/\1>/is', '', $svg);

        // Strip all on* attributes (like onload, onclick)
        $svg = preg_replace('/ on\w+="[^"]*"/i', '', $svg);
        $svg = preg_replace("/ on\w+='[^']*'/i", '', $svg);

        // Save the sanitized SVG back to file
        file_put_contents($file, $svg);
    }
}
add_action('wp_handle_upload', function ($upload) {
    studio_sanitize_svg_file($upload['file']);
    return $upload;
});

/**
 * Allow WebP images to be uploaded securely
 */
function studio_allow_webp_uploads($mimes)
{
    if (user_can_('manage_options')) {
        $mimes['webp'] = 'image/webp';
    }

    return $mimes;
}
add_filter('upload_mimes', 'studio_allow_webp_uploads');

/**
 * Fix incorrect filetype detection for WebP images on some servers.
 *
 * @param array  $data     File type data.
 * @param string $file     Full path to the file.
 * @param string $filename File name.
 * @param array  $mimes    Allowed mime types.
 * @return array
 */
function studio_fix_webp_filetype($data, $file, $filename, $mimes)
{
    if (false !== strpos($filename, '.webp')) {
        $data['ext']  = 'webp';
        $data['type'] = 'image/webp';
    }
    return $data;
}
add_filter('wp_check_filetype_and_ext', 'studio_fix_webp_filetype', 10, 4);
