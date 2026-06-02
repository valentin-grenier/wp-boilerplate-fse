<?php
/**
 * Title: Hero — centered
 * Slug: studioval-boilerplate/hero-centered
 * Categories: studioval-boilerplate
 * Description: Centered hero with a heading, a subheading and a call-to-action button.
 * Keywords: hero, cta, landing
 * Viewport Width: 1200
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}
?>
<!-- wp:group {"align":"full","layout":{"type":"constrained"}} -->
<div class="wp-block-group alignfull" style="padding-top:var(--wp--preset--spacing--lg);padding-bottom:var(--wp--preset--spacing--lg)">

	<!-- wp:heading {"textAlign":"center","level":1,"align":"wide"} -->
	<h1 class="wp-block-heading alignwide has-text-align-center"><?php echo esc_html_x( 'Hero title', 'Pattern placeholder', 'studioval-boilerplate' ); ?></h1>
	<!-- /wp:heading -->

	<!-- wp:paragraph {"align":"center"} -->
	<p class="has-text-align-center"><?php echo esc_html_x( 'A short supporting sentence that explains the value proposition.', 'Pattern placeholder', 'studioval-boilerplate' ); ?></p>
	<!-- /wp:paragraph -->

	<!-- wp:buttons {"layout":{"type":"flex","justifyContent":"center"}} -->
	<div class="wp-block-buttons">
		<!-- wp:button -->
		<div class="wp-block-button"><a class="wp-block-button__link wp-element-button" href="#"><?php echo esc_html_x( 'Call to action', 'Pattern placeholder', 'studioval-boilerplate' ); ?></a></div>
		<!-- /wp:button -->
	</div>
	<!-- /wp:buttons -->

</div>
<!-- /wp:group -->
