---
name: wp-create-post-type
description: Scaffold a native WordPress Custom Post Type registration in inc/post-types.php. No ACF required. Invoke when the user asks to add a CPT, custom post type, or register a new content type.
---

# wp-create-post-type skill

## When to invoke

- User asks to add a CPT / custom post type.
- User asks to register a new content type (e.g. "Portfolio", "Testimonials", "Events").

## Conventions

- All CPTs go in `wp-content/themes/theme-fse/inc/post-types.php`, inside `sv_boilerplate_register_post_types()`.
- Function and hook prefix: `sv_boilerplate_` (substituted by `bin/setup.sh`).
- Text-domain: `studioval-boilerplate`.
- Always set `show_in_rest: true` for block editor compatibility.
- Use `rewrite: array( 'slug' => 'your-slug' )` for clean URLs.

## Template

```php
// CPT "{Label}"
$labels = array(
    'name'               => _x( '{Labels}', 'Post Type General Name', 'studioval-boilerplate' ),
    'singular_name'      => _x( '{Label}', 'Post Type Singular Name', 'studioval-boilerplate' ),
    'menu_name'          => __( '{Labels}', 'studioval-boilerplate' ),
    'name_admin_bar'     => __( '{Label}', 'studioval-boilerplate' ),
    'all_items'          => __( 'All {Labels}', 'studioval-boilerplate' ),
    'add_new_item'       => __( 'Add New {Label}', 'studioval-boilerplate' ),
    'add_new'            => __( 'Add New', 'studioval-boilerplate' ),
    'new_item'           => __( 'New {Label}', 'studioval-boilerplate' ),
    'edit_item'          => __( 'Edit {Label}', 'studioval-boilerplate' ),
    'update_item'        => __( 'Update {Label}', 'studioval-boilerplate' ),
    'view_item'          => __( 'View {Label}', 'studioval-boilerplate' ),
    'search_items'       => __( 'Search {Labels}', 'studioval-boilerplate' ),
    'not_found'          => __( 'No {label} found', 'studioval-boilerplate' ),
    'not_found_in_trash' => __( 'No {label} found in trash', 'studioval-boilerplate' ),
);

$args = array(
    'label'               => __( '{Label}', 'studioval-boilerplate' ),
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
    'show_in_rest'        => true,
    'has_archive'         => true,
    'rewrite'             => array( 'slug' => '{slug}' ),
    'publicly_queryable'  => true,
    'capability_type'     => 'post',
);

register_post_type( '{slug}', $args );
```

## Checklist after adding

1. Flush rewrite rules: `ddev wp rewrite flush` or deactivate/reactivate the theme.
2. If the CPT needs custom fields, use the `wp-create-meta-box` skill.
3. If the CPT needs a custom taxonomy, use the `wp-create-taxonomy` skill.
4. Add templates for the CPT archive/single if needed (`templates/archive-{slug}.html`, `templates/single-{slug}.html`).
5. Run `composer lint` — no new errors expected.
