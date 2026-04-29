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

// Dynamic block — markup is rendered by block-example-dynamic.php on the front-end.
const Save = () => null;

registerBlockType('studioval/block-example-dynamic', {
	apiVersion: 3,
	title: __('Block Example Dynamic', 'studioval-boilerplate'),
	description: __('Un bloc personnalisé nommé block-example-dynamic.', 'studioval-boilerplate'),
	category: 'studioval',
	icon: 'screenoptions',
	keywords: ['block-example-dynamic'],
	render: 'file:./block-example-dynamic.php',
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
