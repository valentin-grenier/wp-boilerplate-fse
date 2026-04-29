<?php
/**
 * Block render template — Block Example Dynamic.
 *
 * @var array    $attributes Block attributes.
 * @var string   $content    Inner block content (empty for blocks without InnerBlocks).
 * @var WP_Block $block      Block instance.
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly.
}

$wrapper_attributes = get_block_wrapper_attributes();
?>
<div <?php echo wp_kses_data( $wrapper_attributes ); ?>>
	<p>Block Example Dynamic — front-end placeholder.</p>
</div>
