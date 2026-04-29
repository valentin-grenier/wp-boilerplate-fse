const fs = require('fs');
const path = require('path');
const readline = require('readline');

const args = process.argv.slice(2);
const blockName = args[0];

if (!blockName) {
	console.error('❌ Please provide a block name.');
	console.error('Usage: npm run make-block [block-name]');
	console.error('');
	console.error('Example:');
	console.error('  npm run make-block my-block');
	process.exit(1);
}

const blocksDir = path.join(__dirname, '..', 'blocks');
const blockDir = path.join(blocksDir, blockName);

if (fs.existsSync(blockDir)) {
	console.error(`❌ Block "${blockName}" already exists.`);
	process.exit(1);
}

const rl = readline.createInterface({
	input: process.stdin,
	output: process.stdout,
});

console.log('');
rl.question(
	'Block type?\n  1) Static (saved in post content)\n  2) Dynamic (PHP server-side rendering)\n\nChoose [1-2]: ',
	(answer) => {
		const isDynamic = answer === '2';

		createBlock(blockName, isDynamic);
		rl.close();
	}
);

function createBlock(blockName, isDynamic) {
	const blocksDir = path.join(__dirname, '..', 'blocks');
	const blockDir = path.join(blocksDir, blockName);

	fs.mkdirSync(blockDir, { recursive: true });

	const titleCase = blockName
		.split('-')
		.map((word) => word.charAt(0).toUpperCase() + word.slice(1))
		.join(' ');

	// === ${blockName}.js (Editor script) ===
	// SCSS is intentionally not imported here — webpack discovers
	// ${blockName}.scss / ${blockName}-editor.scss as separate entries so
	// shared and editor-only styles compile to distinct CSS bundles.
	const blockJs = `import { registerBlockType } from '@wordpress/blocks';
import { useBlockProps, RichText } from '@wordpress/block-editor';
import { __ } from '@wordpress/i18n';

function Edit({ attributes, setAttributes }) {
	const blockProps = useBlockProps();

	return (
		<div {...blockProps}>
			<RichText
				tagName="p"
				value={attributes.content}
				onChange={(content) => setAttributes({ content })}
				placeholder={__('Saisir le contenu…', 'studioval-boilerplate')}
			/>
		</div>
	);
}

${
	isDynamic
		? `// Dynamic block — markup is rendered by ${blockName}.php on the front-end.
const Save = () => null;`
		: `function Save({ attributes }) {
	const blockProps = useBlockProps.save();

	return (
		<div {...blockProps}>
			<RichText.Content tagName="p" value={attributes.content} />
		</div>
	);
}`
}

registerBlockType('studioval/${blockName}', {
	apiVersion: 3,
	title: __('${titleCase}', 'studioval-boilerplate'),
	description: __('Un bloc personnalisé nommé ${blockName}.', 'studioval-boilerplate'),
	category: 'studioval',
	icon: 'screenoptions',
	keywords: ['${blockName}'],${
		isDynamic
			? `
	render: 'file:./${blockName}.php',`
			: ''
	}
	supports: {
		align: true,
		anchor: true,
		html: false,
	},
	attributes: {
		content: {
			type: 'string',
			default: '',
		},
	},
	edit: Edit,
	save: Save,
});
`;
	fs.writeFileSync(path.join(blockDir, `${blockName}.js`), blockJs);

	// === ${blockName}.scss (shared styles, editor + front-end) ===
	fs.writeFileSync(
		path.join(blockDir, `${blockName}.scss`),
		`.wp-block-studioval-${blockName} {
	// Block-scoped styles.
}
`
	);

	// === ${blockName}-editor.scss (editor-only styles) ===
	fs.writeFileSync(
		path.join(blockDir, `${blockName}-editor.scss`),
		`.wp-block-studioval-${blockName} {
	// Editor-only styles.
}
`
	);

	// === ${blockName}-frontend.js (front-end script — both static and dynamic) ===
	const frontendJs = `document.addEventListener('DOMContentLoaded', () => {
	const blocks = document.querySelectorAll('.wp-block-studioval-${blockName}');

	blocks.forEach((block) => {
		// Front-end behaviour for ${titleCase} goes here.
		// eslint-disable-next-line no-console
		console.log('${titleCase} block initialized', block);
	});
});
`;
	fs.writeFileSync(path.join(blockDir, `${blockName}-frontend.js`), frontendJs);

	// === ${blockName}.php (dynamic blocks only — server render template) ===
	if (isDynamic) {
		const phpTemplate = `<?php
/**
 * Block render template — ${titleCase}.
 *
 * @var array    $attributes Block attributes.
 * @var string   $content    Inner block content (empty for blocks without InnerBlocks).
 * @var WP_Block $block      Block instance.
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly.
}

$content_attr = isset( $attributes['content'] ) ? $attributes['content'] : '';

$wrapper_attributes = get_block_wrapper_attributes();
?>
<div <?php echo wp_kses_data( $wrapper_attributes ); ?>>
	<p><?php echo esc_html( $content_attr ); ?></p>
</div>
`;
		fs.writeFileSync(path.join(blockDir, `${blockName}.php`), phpTemplate);
	}

	// === Summary ===
	console.log('');
	console.log(
		`✅ ${isDynamic ? 'Dynamic' : 'Static'} block "${blockName}" created in ./blocks/${blockName}`
	);
	console.log(`   - ${blockName}.js          (editor: registerBlockType + edit + save)`);
	console.log(`   - ${blockName}.scss        (shared styles)`);
	console.log(`   - ${blockName}-editor.scss (editor-only styles)`);
	console.log(`   - ${blockName}-frontend.js (front-end script)`);
	if (isDynamic) {
		console.log(`   - ${blockName}.php         (PHP render template)`);
	}
	console.log('');
	console.log('Next:');
	console.log('   - npm run dev       # rebuild and watch');
	console.log(
		`   - inc/blocks.php picks up the compiled bundles automatically — no manual registration.`
	);
}
