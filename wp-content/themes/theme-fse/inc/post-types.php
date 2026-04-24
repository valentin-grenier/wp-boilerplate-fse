<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly.
}

/**
 * Register Custom Post Types
 *
 */
function studio_register_post_types() {
	// CPT "CPT"
	$labels = array(
		'name'              => _x( 'CPTs', 'Post Type General Name', 'studioval-boilerplate' ),
		'singular_name'     => _x( 'CPT', 'Post Type Singular Name', 'studioval-boilerplate' ),
		'menu_name'         => __( 'CPTs', 'studioval-boilerplate' ),
		'name_admin_bar'    => __( 'CPT', 'studioval-boilerplate' ),
		'archives'          => __( 'CPT Archives', 'studioval-boilerplate' ),
		'attributes'        => __( 'CPT Attributes', 'studioval-boilerplate' ),
		'parent_item_colon' => __( 'Parent CPT:', 'studioval-boilerplate' ),
		'all_items'         => __( 'All CPTs', 'studioval-boilerplate' ),
		'add_new_item'      => __( 'Add New CPT', 'studioval-boilerplate' ),
		'add_new'           => __( 'Add New', 'studioval-boilerplate' ),
		'new_item'          => __( 'New CPT', 'studioval-boilerplate' ),
		'edit_item'         => __( 'Edit CPT', 'studioval-boilerplate' ),
		'update_item'       => __( 'Update CPT', 'studioval-boilerplate' ),
		'view_item'         => __( 'View CPT', 'studioval-boilerplate' ),
		'view_items'        => __( 'View CPTs', 'studioval-boilerplate' ),
		'search_items'      => __( 'Search CPTs', 'studioval-boilerplate' ),
	);

	$args = array(
		'label'               => __( 'CPT', 'studioval-boilerplate' ),
		'description'         => __( 'Custom Post Type Description', 'studioval-boilerplate' ),
		'labels'              => $labels,
		'supports'            => array( 'title', 'editor', 'thumbnail', 'revisions' ),
		'hierarchical'        => false,
		'public'              => true,
		'show_ui'             => true,
		'show_in_menu'        => true,
		'menu_position'       => 5,
		'menu_icon'           => 'dashicons-admin-post',
		'show_in_admin_bar'   => true,
		'show_in_nav_menus'   => true,
		'can_export'          => true,
		'has_archive'         => true,
		'exclude_from_search' => false,
		'publicly_queryable'  => true,
		'capability_type'     => 'post',
	);

	register_post_type( 'cpt', $args );

	// Taxonomy "CPT Category"
	$labels = array(
		'name'                       => _x( 'CPT Categories', 'Taxonomy General Name', 'studioval-boilerplate' ),
		'singular_name'              => _x( 'CPT Category', 'Taxonomy Singular Name', 'studioval-boilerplate' ),
		'menu_name'                  => __( 'CPT Categories', 'studioval-boilerplate' ),
		'all_items'                  => __( 'All CPT Categories', 'studioval-boilerplate' ),
		'parent_item'                => __( 'Parent CPT Category', 'studioval-boilerplate' ),
		'parent_item_colon'          => __( 'Parent CPT Category:', 'studioval-boilerplate' ),
		'new_item_name'              => __( 'New CPT Category Name', 'studioval-boilerplate' ),
		'add_new_item'               => __( 'Add New CPT Category', 'studioval-boilerplate' ),
		'edit_item'                  => __( 'Edit CPT Category', 'studioval-boilerplate' ),
		'update_item'                => __( 'Update CPT Category', 'studioval-boilerplate' ),
		'view_item'                  => __( 'View CPT Category', 'studioval-boilerplate' ),
		'separate_items_with_commas' => __( 'Separate CPT categories with commas', 'studioval-boilerplate' ),
		'add_or_remove_items'        => __( 'Add or remove CPT categories', 'studioval-boilerplate' ),
		'choose_from_most_used'      => __( 'Choose from the most used CPT categories', 'studioval-boilerplate' ),
	);

	$args = array(
		'labels'            => $labels,
		'hierarchical'      => true,
		'public'            => true,
		'show_ui'           => true,
		'show_admin_column' => true,
		'query_var'         => true,
		'rewrite'           => array( 'slug' => 'cpt-category' ),
		'show_in_rest'      => true,
	);

	register_taxonomy( 'cpt_category', 'cpt', $args );
}
add_action( 'init', 'studio_register_post_types' );
