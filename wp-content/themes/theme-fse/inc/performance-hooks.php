<?php

/**
 * Disable emoji scripts and styles.
 *
 * Removes front-end, admin, and feed emoji-related scripts and styles.
 *
 * @return void
 */
function studio_disable_emojis()
{
    remove_action('wp_head', 'print_emoji_detection_script', 7);
    remove_action('wp_print_styles', 'print_emoji_styles');
    remove_action('admin_print_scripts', 'print_emoji_detection_script');
    remove_action('admin_print_styles', 'print_emoji_styles');
    remove_filter('the_content_feed', 'wp_staticize_emoji');
    remove_filter('comment_text_rss', 'wp_staticize_emoji');
    remove_filter('wp_mail', 'wp_staticize_emoji_for_email');
}
add_action('init', 'studio_disable_emojis');

/**
 * Disable oEmbed and REST API discovery links in <head>.
 *
 * @return void
 */
function studio_remove_head_junk()
{
    remove_action('wp_head', 'rest_output_link_wp_head');
    remove_action('wp_head', 'wp_oembed_add_discovery_links');
    remove_action('template_redirect', 'rest_output_link_header', 11);
}
add_action('init', 'studio_remove_head_junk');

/**
 * Deregister wp-embed.js script if not used.
 *
 * @return void
 */
function studio_remove_wp_embed_script()
{
    wp_deregister_script('wp-embed');
}
add_action('wp_footer', 'studio_remove_wp_embed_script');

/**
 * Force lazy-loading on iframes inside post content.
 *
 * @param string $content The post content.
 * @return string
 */
function studio_lazyload_iframes($content)
{
    return preg_replace('/<iframe\s/', '<iframe loading="lazy" ', $content);
}
add_filter('the_content', 'studio_lazyload_iframes');
