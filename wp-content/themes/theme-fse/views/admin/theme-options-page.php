<?php

/**
 * Admin view: Theme Options Page
 * Loaded by sv_boilerplate_theme_options_page() in inc/theme-option.php
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly
}

if ( ! current_user_can( 'manage_options' ) ) {
	return;
}
?>

<div class="sv-boilerplate-theme-options-page wrap">
	<h1 class="sv-boilerplate-theme-options-page__title"><?php esc_html_e( 'Options du thème', 'studioval-boilerplate' ); ?></h1>
	<div id="sv-boilerplate-theme-options-page__root"></div>
</div>
