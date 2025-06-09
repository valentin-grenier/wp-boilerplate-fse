<?php

/**
 * Register Custom Post Types
 * 
 */
function studio_register_post_types()
{
    // CPT "CPT"
    $labels = array(
        'name'                  => _x('CPTs', 'Post Type General Name', 'text_domain'),
        'singular_name'         => _x('CPT', 'Post Type Singular Name', 'text_domain'),
        'menu_name'             => __('CPTs', 'text_domain'),
        'name_admin_bar'        => __('CPT', 'text_domain'),
        'archives'              => __('CPT Archives', 'text_domain'),
        'attributes'            => __('CPT Attributes', 'text_domain'),
        'parent_item_colon'     => __('Parent CPT:', 'text_domain'),
        'all_items'             => __('All CPTs', 'text_domain'),
        'add_new_item'          => __('Add New CPT', 'text_domain'),
        'add_new'               => __('Add New', 'text_domain'),
        'new_item'              => __('New CPT', 'text_domain'),
        'edit_item'             => __('Edit CPT', 'text_domain'),
        'update_item'           => __('Update CPT', 'text_domain'),
        'view_item'             => __('View CPT', 'text_domain'),
        'view_items'            => __('View CPTs', 'text_domain'),
        'search_items'          => __('Search CPTs', 'text_domain'),
    );

    $args = array(
        'label'                 => __('CPT', 'text_domain'),
        'description'           => __('Custom Post Type Description', 'text_domain'),
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
        'name'                       => _x('CPT Categories', 'Taxonomy General Name', 'text_domain'),
        'singular_name'              => _x('CPT Category', 'Taxonomy Singular Name', 'text_domain'),
        'menu_name'                  => __('CPT Categories', 'text_domain'),
        'all_items'                  => __('All CPT Categories', 'text_domain'),
        'parent_item'                => __('Parent CPT Category', 'text_domain'),
        'parent_item_colon'          => __('Parent CPT Category:', 'text_domain'),
        'new_item_name'              => __('New CPT Category Name', 'text_domain'),
        'add_new_item'               => __('Add New CPT Category', 'text_domain'),
        'edit_item'                  => __('Edit CPT Category', 'text_domain'),
        'update_item'                => __('Update CPT Category', 'text_domain'),
        'view_item'                  => __('View CPT Category', 'text_domain'),
        'separate_items_with_commas' => __('Separate CPT categories with commas', 'text_domain'),
        'add_or_remove_items'        => __('Add or remove CPT categories', 'text_domain'),
        'choose_from_most_used'      => __('Choose from the most used CPT categories', 'text_domain'),
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
