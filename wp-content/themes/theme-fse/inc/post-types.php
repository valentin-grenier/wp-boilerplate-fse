<?php

/**
 * Register Custom Post Types
 * 
 */
function studio_register_post_types()
{
    // CPT "CPT"
    $labels = array(
        'name'                  => _x('CPTs', 'Post Type General Name', 'studio-val'),
        'singular_name'         => _x('CPT', 'Post Type Singular Name', 'studio-val'),
        'menu_name'             => __('CPTs', 'studio-val'),
        'name_admin_bar'        => __('CPT', 'studio-val'),
        'archives'              => __('CPT Archives', 'studio-val'),
        'attributes'            => __('CPT Attributes', 'studio-val'),
        'parent_item_colon'     => __('Parent CPT:', 'studio-val'),
        'all_items'             => __('All CPTs', 'studio-val'),
        'add_new_item'          => __('Add New CPT', 'studio-val'),
        'add_new'               => __('Add New', 'studio-val'),
        'new_item'              => __('New CPT', 'studio-val'),
        'edit_item'             => __('Edit CPT', 'studio-val'),
        'update_item'           => __('Update CPT', 'studio-val'),
        'view_item'             => __('View CPT', 'studio-val'),
        'view_items'            => __('View CPTs', 'studio-val'),
        'search_items'          => __('Search CPTs', 'studio-val'),
    );

    $args = array(
        'label'                 => __('CPT', 'studio-val'),
        'description'           => __('Custom Post Type Description', 'studio-val'),
        'labels'                => $labels,
        'supports'              => array('title', 'editor', 'thumbnail', 'revisions'),
        'hierarchical'          => false,
        'public'                => true,
        'show_ui'               => true,
        'show_in_menu'          => true,
        'menu_position'         => 5,
        'menu_icon'             => 'dashicons-admin-post',
        'show_in_admin_bar'     => true,
        'show_in_nav_menus'     => true,
        'can_export'            => true,
        'has_archive'           => true,
        'exclude_from_search'   => false,
        'publicly_queryable'    => true,
        'capability_type'       => 'post',
    );

    register_post_type('cpt', $args);

    // Taxonomy "CPT Category"
    $labels = array(
        'name'                       => _x('CPT Categories', 'Taxonomy General Name', 'studio-val'),
        'singular_name'              => _x('CPT Category', 'Taxonomy Singular Name', 'studio-val'),
        'menu_name'                  => __('CPT Categories', 'studio-val'),
        'all_items'                  => __('All CPT Categories', 'studio-val'),
        'parent_item'                => __('Parent CPT Category', 'studio-val'),
        'parent_item_colon'          => __('Parent CPT Category:', 'studio-val'),
        'new_item_name'              => __('New CPT Category Name', 'studio-val'),
        'add_new_item'               => __('Add New CPT Category', 'studio-val'),
        'edit_item'                  => __('Edit CPT Category', 'studio-val'),
        'update_item'                => __('Update CPT Category', 'studio-val'),
        'view_item'                  => __('View CPT Category', 'studio-val'),
        'separate_items_with_commas' => __('Separate CPT categories with commas', 'studio-val'),
        'add_or_remove_items'        => __('Add or remove CPT categories', 'studio-val'),
        'choose_from_most_used'      => __('Choose from the most used CPT categories', 'studio-val'),
    );

    $args = array(
        'labels'                     => $labels,
        'hierarchical'               => true,
        'public'                     => true,
        'show_ui'                    => true,
        'show_admin_column'          => true,
        'query_var'                  => true,
        'rewrite'                    => array('slug' => 'cpt-category'),
        'show_in_rest'               => true,
    );

    register_taxonomy('cpt_category', 'cpt', $args);
}
add_action('init', 'studio_register_post_types');
