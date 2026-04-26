---
name: wp-create-meta-box
description: Scaffold a native WordPress meta box with custom fields using the Meta Box API and register_meta(). No ACF required. Invoke when the user asks to add custom fields, a meta box, or post metadata to a post type.
---

# wp-create-meta-box skill

## When to invoke

- User asks to add custom fields or a meta box to a post type.
- User wants to store per-post metadata (e.g. subtitle, external URL, event date).
- User wants to replace an ACF field group with native WP code.

## Conventions

- Create a dedicated file: `wp-content/themes/theme-fse/inc/meta-{slug}.php`.
- Register it via the glob in `functions.php` — no manual require needed.
- Function prefix: `sv_boilerplate_`. Meta key prefix: `_sv_boilerplate_`.
- Text-domain: `studioval-boilerplate`.
- ABSPATH guard at the top.
- Always verify nonce with `wp_verify_nonce()` on save.
- Always check `current_user_can( 'edit_post', $post_id )` on save.
- Sanitize on save, escape on output.
- Use `register_meta()` with `show_in_rest: true` for block editor / REST API access.

## Template

```php
<?php

if ( ! defined( 'ABSPATH' ) ) {
    exit;
}

/**
 * Register post meta for REST API and block editor access.
 */
function sv_boilerplate_register_{slug}_meta() {
    register_post_meta(
        '{post-type}',
        '_sv_boilerplate_{field}',
        array(
            'type'              => 'string',
            'single'            => true,
            'show_in_rest'      => true,
            'sanitize_callback' => 'sanitize_text_field',
            'auth_callback'     => function () {
                return current_user_can( 'edit_posts' );
            },
        )
    );
}
add_action( 'init', 'sv_boilerplate_register_{slug}_meta' );

/**
 * Add the meta box.
 */
function sv_boilerplate_add_{slug}_meta_box() {
    add_meta_box(
        'sv_boilerplate_{slug}',
        __( '{Label}', 'studioval-boilerplate' ),
        'sv_boilerplate_render_{slug}_meta_box',
        '{post-type}',
        'normal',
        'default'
    );
}
add_action( 'add_meta_boxes', 'sv_boilerplate_add_{slug}_meta_box' );

/**
 * Render the meta box HTML.
 *
 * @param WP_Post $post Current post object.
 */
function sv_boilerplate_render_{slug}_meta_box( $post ) {
    wp_nonce_field( 'sv_boilerplate_{slug}_save', 'sv_boilerplate_{slug}_nonce' );

    $value = get_post_meta( $post->ID, '_sv_boilerplate_{field}', true );
    ?>
    <p>
        <label for="sv_boilerplate_{field}"><?php esc_html_e( '{Field Label}', 'studioval-boilerplate' ); ?></label><br>
        <input
            type="text"
            id="sv_boilerplate_{field}"
            name="sv_boilerplate_{field}"
            value="<?php echo esc_attr( $value ); ?>"
            class="widefat"
        >
    </p>
    <?php
}

/**
 * Save meta box data.
 *
 * @param int $post_id Post ID.
 */
function sv_boilerplate_save_{slug}_meta( $post_id ) {
    if (
        ! isset( $_POST['sv_boilerplate_{slug}_nonce'] ) ||
        ! wp_verify_nonce( sanitize_key( $_POST['sv_boilerplate_{slug}_nonce'] ), 'sv_boilerplate_{slug}_save' )
    ) {
        return;
    }

    if ( defined( 'DOING_AUTOSAVE' ) && DOING_AUTOSAVE ) {
        return;
    }

    if ( ! current_user_can( 'edit_post', $post_id ) ) {
        return;
    }

    if ( isset( $_POST['sv_boilerplate_{field}'] ) ) {
        update_post_meta(
            $post_id,
            '_sv_boilerplate_{field}',
            sanitize_text_field( wp_unslash( $_POST['sv_boilerplate_{field}'] ) )
        );
    }
}
add_action( 'save_post', 'sv_boilerplate_save_{slug}_meta' );
```

## Reading the meta value in a template

```php
$value = get_post_meta( get_the_ID(), '_sv_boilerplate_{field}', true );
if ( $value ) {
    echo esc_html( $value );
}
```

## Checklist after adding

1. Run `composer lint` — verify nonce, capability check, sanitize, and escape are present.
2. Test save/retrieve in wp-admin edit screen.
3. If the field needs to be editable in the block editor sidebar, use `useEntityProp` in JS with the registered meta key.
