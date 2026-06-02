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
				label={__('Block Example Static', 'theme-fse')}
				instructions={__(
					'Bloc d’exemple statique — le markup côté front est défini en dur dans Save.',
					'theme-fse'
				)}
			/>
		</div>
	);
}

function Save() {
	const blockProps = useBlockProps.save();

	return (
		<div {...blockProps}>
			<p>Block Example Static — front-end placeholder.</p>
		</div>
	);
}

registerBlockType('studioval/block-example-static', {
	apiVersion: 3,
	title: __('Block Example Static', 'theme-fse'),
	description: __('Un bloc d’exemple statique.', 'theme-fse'),
	category: 'studioval',
	icon: 'screenoptions',
	keywords: ['block-example-static'],
	supports: {
		align: true,
		anchor: true,
		html: false,
	},
	edit: Edit,
	save: Save,
});
