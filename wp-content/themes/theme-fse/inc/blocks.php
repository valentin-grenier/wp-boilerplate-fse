<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly.
}

/**
 * Custom block loading.
 *
 * Blocks live in `_dev/blocks/{name}/` and compile to `dist/blocks/{name}/`.
 * Each block can ship up to four bundles, all optional except `block.js`:
 *   block.js          — editor: registerBlockType + edit + save
 *   block.css         — shared styles (editor + front-end)
 *   block-editor.css  — editor-only styles
 *   block-frontend.js — front-end behaviour
 *
 * Registration is JS-side (each block calls `registerBlockType` itself), so
 * no `block.json` and no `register_block_type()` here. The PHP side only
 * enqueues the compiled bundles.
 */

/**
 * Glob every block folder under `dist/blocks/` and return their names.
 *
 * @return string[]
 */
function sv_boilerplate_get_block_names() {
	$dirs = glob( get_template_directory() . '/dist/blocks/*', GLOB_ONLYDIR );

	if ( ! is_array( $dirs ) ) {
		return array();
	}

	return array_map( 'basename', $dirs );
}

/**
 * Enqueue editor-side block assets: registerBlockType script and styles.
 *
 * @return void
 */
function sv_boilerplate_enqueue_block_editor_assets() {
	$block_dir_uri = get_template_directory_uri() . '/dist/blocks';
	$block_dir     = get_template_directory() . '/dist/blocks';

	foreach ( sv_boilerplate_get_block_names() as $name ) {
		$handle = 'sv-block-' . $name;

		$editor_js  = $block_dir . '/' . $name . '/block.js';
		$shared_css = $block_dir . '/' . $name . '/block.css';
		$editor_css = $block_dir . '/' . $name . '/block-editor.css';

		if ( file_exists( $editor_js ) ) {
			wp_enqueue_script(
				$handle,
				$block_dir_uri . '/' . $name . '/block.js',
				array( 'wp-blocks', 'wp-block-editor', 'wp-components', 'wp-element', 'wp-i18n' ),
				filemtime( $editor_js ),
				true
			);
		}

		if ( file_exists( $shared_css ) ) {
			wp_enqueue_style(
				$handle . '-style',
				$block_dir_uri . '/' . $name . '/block.css',
				array(),
				filemtime( $shared_css )
			);
		}

		if ( file_exists( $editor_css ) ) {
			wp_enqueue_style(
				$handle . '-editor',
				$block_dir_uri . '/' . $name . '/block-editor.css',
				array(),
				filemtime( $editor_css )
			);
		}
	}
}
add_action( 'enqueue_block_editor_assets', 'sv_boilerplate_enqueue_block_editor_assets' );

/**
 * Enqueue front-end block assets: shared styles and per-block front-end JS.
 *
 * @return void
 */
function sv_boilerplate_enqueue_block_frontend_assets() {
	$block_dir_uri = get_template_directory_uri() . '/dist/blocks';
	$block_dir     = get_template_directory() . '/dist/blocks';

	foreach ( sv_boilerplate_get_block_names() as $name ) {
		$handle = 'sv-block-' . $name;

		$shared_css  = $block_dir . '/' . $name . '/block.css';
		$frontend_js = $block_dir . '/' . $name . '/block-frontend.js';

		if ( file_exists( $shared_css ) ) {
			wp_enqueue_style(
				$handle . '-style',
				$block_dir_uri . '/' . $name . '/block.css',
				array(),
				filemtime( $shared_css )
			);
		}

		if ( file_exists( $frontend_js ) ) {
			wp_enqueue_script(
				$handle . '-frontend',
				$block_dir_uri . '/' . $name . '/block-frontend.js',
				array(),
				filemtime( $frontend_js ),
				true
			);
		}
	}
}
add_action( 'wp_enqueue_scripts', 'sv_boilerplate_enqueue_block_frontend_assets' );
