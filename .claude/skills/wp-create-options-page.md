---
name: wp-create-options-page
description: Scaffold a native WordPress admin options page using the Settings API. No ACF required. Invoke when the user asks to add an options page, settings page, or theme settings panel.
---

# wp-create-options-page skill

## When to invoke

- User asks to add an options page, settings page, or admin panel.
- User wants to store theme-level settings (e.g. social links, contact info, API keys).

## Conventions

- Create a dedicated file: `wp-content/themes/theme-fse/inc/options-{slug}.php`.
- Register it in `functions.php` via the existing glob — no manual require needed.
- Function prefix: `sv_boilerplate_`. Option name prefix: `sv_boilerplate_`.
- Text-domain: `studioval-boilerplate`.
- ABSPATH guard at the top of the new file.
- Nonce with `check_admin_referer()` on save.
- Sanitize every input before storing with `update_option()`.
- Always call `settings_errors()` inside the page callback for feedback display.

## Template

```php
<?php

if ( ! defined( 'ABSPATH' ) ) {
    exit;
}

/**
 * Register the {Label} settings page.
 */
function sv_boilerplate_register_{slug}_page() {
    add_theme_page(
        __( '{Label} Settings', 'studioval-boilerplate' ),
        __( '{Label}', 'studioval-boilerplate' ),
        'manage_options',
        'sv-{slug}',
        'sv_boilerplate_render_{slug}_page'
    );
}
add_action( 'admin_menu', 'sv_boilerplate_register_{slug}_page' );

/**
 * Register settings, sections, and fields.
 */
function sv_boilerplate_init_{slug}_settings() {
    register_setting(
        'sv_boilerplate_{slug}_group',
        'sv_boilerplate_{slug}_options',
        array( 'sanitize_callback' => 'sv_boilerplate_sanitize_{slug}_options' )
    );

    add_settings_section(
        'sv_boilerplate_{slug}_section',
        __( '{Section Label}', 'studioval-boilerplate' ),
        '__return_false',
        'sv-{slug}'
    );

    add_settings_field(
        'sv_boilerplate_{slug}_{field}',
        __( '{Field Label}', 'studioval-boilerplate' ),
        'sv_boilerplate_render_{slug}_{field}_field',
        'sv-{slug}',
        'sv_boilerplate_{slug}_section'
    );
}
add_action( 'admin_init', 'sv_boilerplate_init_{slug}_settings' );

/**
 * Sanitize options on save.
 *
 * @param array $input Raw posted values.
 * @return array
 */
function sv_boilerplate_sanitize_{slug}_options( $input ) {
    $clean = array();
    $clean['{field}'] = isset( $input['{field}'] ) ? sanitize_text_field( $input['{field}'] ) : '';
    return $clean;
}

/**
 * Render the {field} input field.
 */
function sv_boilerplate_render_{slug}_{field}_field() {
    $options = get_option( 'sv_boilerplate_{slug}_options', array() );
    $value   = isset( $options['{field}'] ) ? esc_attr( $options['{field}'] ) : '';
    printf(
        '<input type="text" name="sv_boilerplate_{slug}_options[{field}]" value="%s" class="regular-text">',
        $value
    );
}

/**
 * Render the settings page.
 */
function sv_boilerplate_render_{slug}_page() {
    if ( ! current_user_can( 'manage_options' ) ) {
        return;
    }
    ?>
    <div class="wrap">
        <h1><?php echo esc_html( get_admin_page_title() ); ?></h1>
        <?php settings_errors(); ?>
        <form method="post" action="options.php">
            <?php
            settings_fields( 'sv_boilerplate_{slug}_group' );
            do_settings_sections( 'sv-{slug}' );
            submit_button();
            ?>
        </form>
    </div>
    <?php
}
```

## Reading a saved option

```php
$options = get_option( 'sv_boilerplate_{slug}_options', array() );
$value   = $options['{field}'] ?? '';
```

## Checklist after adding

1. Flush the options cache if testing: `ddev wp cache flush`.
2. Run `composer lint` — verify ABSPATH guard, escaping, and nonce are in place.
3. Test the form saves and retrieves correctly in wp-admin.
