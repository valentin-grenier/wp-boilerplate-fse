import { registerBlockType } from '@wordpress/blocks';
import { useBlockProps } from '@wordpress/block-editor';
import { Placeholder } from '@wordpress/components';
import { __ } from '@wordpress/i18n';

function Edit() {
	const blockProps = useBlockProps();

	return (
		<div {...blockProps}>
			<Placeholder
				icon="screenoptions"
				label={__('Block Example Dynamic', 'theme-fse')}
				instructions={__(
					'Bloc d’exemple dynamique — le markup côté front est rendu par block-example-dynamic.php.',
					'theme-fse'
				)}
			/>
		</div>
	);
}

// Dynamic block — markup is rendered by block-example-dynamic.php on the front-end.
const Save = () => null;

registerBlockType('studioval/block-example-dynamic', {
	apiVersion: 3,
	title: __('Block Example Dynamic', 'theme-fse'),
	description: __('Un bloc d’exemple dynamique.', 'theme-fse'),
	category: 'studioval',
	icon: 'screenoptions',
	keywords: ['block-example-dynamic'],
	render: 'file:./block-example-dynamic.php',
	supports: {
		align: true,
		anchor: true,
		html: false,
	},
	edit: Edit,
	save: Save,
});
