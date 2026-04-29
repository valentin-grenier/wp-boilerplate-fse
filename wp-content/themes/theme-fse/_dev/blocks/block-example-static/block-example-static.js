import { registerBlockType } from '@wordpress/blocks';
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

function Save({ attributes }) {
	const blockProps = useBlockProps.save();

	return (
		<div {...blockProps}>
			<RichText.Content tagName="p" value={attributes.content} />
		</div>
	);
}

registerBlockType('studioval/block-example-static', {
	apiVersion: 3,
	title: __('Block Example Static', 'studioval-boilerplate'),
	description: __('Un bloc personnalisé nommé block-example-static.', 'studioval-boilerplate'),
	category: 'studioval',
	icon: 'screenoptions',
	keywords: ['block-example-static'],
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
