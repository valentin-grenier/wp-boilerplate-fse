const { registerBlockType } = wp.blocks;
const { useBlockProps, RichText } = wp.blockEditor;
const { __ } = wp.i18n;

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

registerBlockType('studioval/block', {
	edit: Edit,
	save: Save,
});
