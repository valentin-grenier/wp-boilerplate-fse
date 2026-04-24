<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly.
}

/**
 * Completely disable comments on the site
 */
function sv_boilerplate_disable_comment_support() {
	// Disable support for comments and trackbacks in post types
	$post_types = get_post_types( array( 'public' => true ), 'names' );

	foreach ( $post_types as $post_type ) {
		remove_post_type_support( $post_type, 'comments' );
		remove_post_type_support( $post_type, 'trackbacks' );
	}
}
add_action( 'init', 'sv_boilerplate_disable_comment_support' );

/**
 * Remove comments page in admin menu
 */
function sv_boilerplate_remove_comments_menu() {
	remove_menu_page( 'edit-comments.php' );
}
add_action( 'admin_menu', 'sv_boilerplate_remove_comments_menu' );

/**
 * Redirect any user trying to access comments page
 */
function sv_boilerplate_redirect_comments_page() {
	global $pagenow;

	if ( $pagenow === 'edit-comments.php' ) {
		wp_redirect( admin_url() );
		exit;
	}
}
add_action( 'admin_init', 'sv_boilerplate_redirect_comments_page' );

/**
 * Remove comment columns from the posts list table
 */
function sv_boilerplate_remove_comment_columns( $columns ) {
	if ( isset( $columns['comments'] ) ) {
		unset( $columns['comments'] );
	}
	return $columns;
}
add_filter( 'manage_posts_columns', 'sv_boilerplate_remove_comment_columns' );
add_filter( 'manage_pages_columns', 'sv_boilerplate_remove_comment_columns' );

/**
 * Force comments to be closed on front-end
 */
function sv_boilerplate_disable_comments_status() {
	return false;
}
add_filter( 'comments_open', 'sv_boilerplate_disable_comments_status', 20, 2 );
add_filter( 'pings_open', 'sv_boilerplate_disable_comments_status', 20, 2 );

/**
 * Hide all existing comments.
 */
function sv_boilerplate_hide_existing_comments( $comments ) {
	return array();
}
add_filter( 'comments_array', 'sv_boilerplate_hide_existing_comments', 10, 2 );

/**
 * Unregister recent comments widget.
 */
function sv_boilerplate_disable_comment_widgets() {
	unregister_widget( 'WP_Widget_Recent_Comments' );
}
add_action( 'widgets_init', 'sv_boilerplate_disable_comment_widgets' );

/**
 * Unregister comment-related blocks via JS in the block editor.
 *
 * * Please refer to:
 *   * /inc/block-settings.php
 *   * /assets/js/editor/unregister-blocks.js
 */
