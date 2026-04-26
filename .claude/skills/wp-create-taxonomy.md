---
name: wp-create-taxonomy
description: Scaffold a native WordPress taxonomy registration in inc/post-types.php. No ACF required. Invoke when the user asks to add a taxonomy, category, or tag to a post type.
---

# wp-create-taxonomy skill

## When to invoke

- User asks to add a taxonomy, category, or tag to a CPT.
- User asks to create a custom classification (e.g. "Portfolio Category", "Event Type").

## Conventions

- All taxonomies go in `wp-content/themes/theme-fse/inc/post-types.php`, inside `sv_boilerplate_register_post_types()`, after the CPT they belong to.
- Function and hook prefix: `sv_boilerplate_`.
- Text-domain: `studioval-boilerplate`.
- Always set `show_in_rest: true` for block editor compatibility.
- Hierarchical (`true`) = category-like. Non-hierarchical (`false`) = tag-like.

## Template

```php
// Taxonomy "{Label}" for "{cpt-slug}"
$tax_labels = array(
    'name'                       => _x( '{Labels}', 'Taxonomy General Name', 'studioval-boilerplate' ),
    'singular_name'              => _x( '{Label}', 'Taxonomy Singular Name', 'studioval-boilerplate' ),
    'menu_name'                  => __( '{Labels}', 'studioval-boilerplate' ),
    'all_items'                  => __( 'All {Labels}', 'studioval-boilerplate' ),
    'new_item_name'              => __( 'New {Label} Name', 'studioval-boilerplate' ),
    'add_new_item'               => __( 'Add New {Label}', 'studioval-boilerplate' ),
    'edit_item'                  => __( 'Edit {Label}', 'studioval-boilerplate' ),
    'update_item'                => __( 'Update {Label}', 'studioval-boilerplate' ),
    'view_item'                  => __( 'View {Label}', 'studioval-boilerplate' ),
    'not_found'                  => __( 'No {label} found', 'studioval-boilerplate' ),
);

$tax_args = array(
    'labels'            => $tax_labels,
    'hierarchical'      => true,
    'public'            => true,
    'show_ui'           => true,
    'show_admin_column' => true,
    'show_in_rest'      => true,
    'query_var'         => true,
    'rewrite'           => array( 'slug' => '{tax-slug}' ),
);

register_taxonomy( '{tax-slug}', '{cpt-slug}', $tax_args );
```

## Checklist after adding

1. Flush rewrite rules: `ddev wp rewrite flush`.
2. If the taxonomy is standalone (not tied to a CPT), pass `'post'` or an array of post types as the second argument.
3. Run `composer lint` — no new errors expected.
