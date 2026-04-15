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

// Prompt for block type
const rl = readline.createInterface({
	input: process.stdin,
	output: process.stdout,
});

console.log('');
rl.question('Block type?\n  1) Static (saved in post content)\n  2) Dynamic (PHP server-side rendering)\n\nChoose [1-2]: ', (answer) => {
	const isDynamic = answer === '2';

	createBlock(blockName, isDynamic);
	rl.close();
});

function createBlock(blockName, isDynamic) {
	const blocksDir = path.join(__dirname, '..', 'blocks');
	const blockDir = path.join(blocksDir, blockName);

	fs.mkdirSync(blockDir, { recursive: true });

	const titleCase = blockName
		.split('-')
		.map((word) => word.charAt(0).toUpperCase() + word.slice(1))
		.join(' ');

	// === [block-name].js (Editor Script) ===
	const blockJs = `import { registerBlockType } from '@wordpress/blocks';
import { useBlockProps, RichText } from '@wordpress/block-editor';
import { __ } from '@wordpress/i18n';

import './${blockName}.scss';

import Icon from '../../shared/icon-site.jsx';

registerBlockType('theme-name/${blockName}', {
	apiVersion: 3,
	title: __('${titleCase}', 'theme-name'),
	description: __('Un bloc personnalisé nommé ${blockName}.', 'theme-name'),
	category: 'theme-name',
	icon: { src: Icon },
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
	edit: ({ attributes, setAttributes }) => {
		const blockProps = useBlockProps();

		return (
			<div {...blockProps}>
				<RichText
					tagName="p"
					value={attributes.content}
					onChange={(content) => setAttributes({ content })}
					placeholder={__('Saisir le contenu...', 'theme-name')}
				/>
			</div>
		);
	},
${
	isDynamic
		? `
	// Dynamic block - rendered with PHP
	save: () => null,`
		: `
	save: ({ attributes }) => {
		const blockProps = useBlockProps.save();

		return (
			<div {...blockProps}>
				<RichText.Content tagName="p" value={attributes.content} />
			</div>
		);
	},`
}
});
`;
	fs.writeFileSync(path.join(blockDir, `${blockName}.js`), blockJs);

	// === [block-name]-editor.scss (Editor Styles) ===
	fs.writeFileSync(
		path.join(blockDir, `${blockName}-editor.scss`),
		`.wp-block-theme-name-${blockName} {}
`
	);

	// === [block-name].scss (Frontend Styles) ===
	fs.writeFileSync(
		path.join(blockDir, `${blockName}.scss`),
		`.wp-block-theme-name-${blockName} {}
`
	);

	// === [block-name]-frontend.js (Frontend JavaScript) ===
	if (isDynamic) {
		const frontendJs = `document.addEventListener('DOMContentLoaded', () => {
	const blocks = document.querySelectorAll('.wp-block-theme-name-${blockName}');

	blocks.forEach((block) => {
		console.log('${titleCase} block initialized', block);
	});
});
`;
		fs.writeFileSync(path.join(blockDir, `${blockName}-frontend.js`), frontendJs);
	}

	// === [block-name].php (PHP render template for dynamic blocks) ===
	if (isDynamic) {
		const phpTemplate = `<?php
/**
 * Block Name: ${titleCase}
 * 
 * @param array $attributes Block attributes.
 * @param string $content Block content.
 * @param WP_Block $block Block instance.
 */

$classes = [];

if (isset($attributes['align'])) {
	$classes[] = 'align' . $attributes['align'];
}

if (isset($attributes['className'])) {
	$classes[] = $attributes['className'];
}

$wrapper_attributes = get_block_wrapper_attributes([
	'class' => implode(' ', $classes),
]);
?>

<div <?php echo $wrapper_attributes; ?>>
	<p><?php echo esc_html('${blockName}'); ?></p>
</div>
`;
		fs.writeFileSync(path.join(blockDir, `${blockName}.php`), phpTemplate);
		console.log('');
		console.log(`✅ Dynamic block "${blockName}" created in ./blocks/${blockName}`);
		console.log(`   - ${blockName}.js (editor)`);
		console.log(`   - ${blockName}.php (render template)`);
		console.log(`   - ${blockName}.scss (frontend styles)`);
		console.log(`   - ${blockName}-editor.scss (editor styles)`);
		console.log(`   - ${blockName}-frontend.js (frontend script)`);
	} else {
		console.log('');
		console.log(`✅ Static block "${blockName}" created in ./blocks/${blockName}`);
		console.log(`   - ${blockName}.js (editor + save)`);
		console.log(`   - ${blockName}.scss (frontend styles)`);
		console.log(`   - ${blockName}-editor.scss (editor styles)`);
	}
}
