import React from 'react';

const LAYOUTS = [
	{
		value: 'basic',
		label: 'Basique',
		description: 'Formulaire centré, fond coloré',
	},
	{
		value: 'image-left',
		label: 'Image à gauche',
		description: 'Formulaire à droite',
	},
	{
		value: 'image-right',
		label: 'Image à droite',
		description: 'Formulaire à gauche',
	},
];

function LayoutIllustration( { value } ) {
	if ( value === 'basic' ) {
		return (
			<div className="clp-illustration clp-illustration--basic">
				<div className="clp-illustration__form" />
			</div>
		);
	}

	return (
		<div className={ `clp-illustration clp-illustration--split clp-illustration--${ value }` }>
			<div className="clp-illustration__image" />
			<div className="clp-illustration__form-panel">
				<div className="clp-illustration__form" />
			</div>
		</div>
	);
}

export default function LayoutPanel( { settings, onChange } ) {
	return (
		<div className="clp-layout-selector">
			{ LAYOUTS.map( ( { value, label, description } ) => (
				<button
					key={ value }
					type="button"
					className={ `clp-layout-option${ settings.layout === value ? ' is-selected' : '' }` }
					onClick={ () => onChange( 'layout', value ) }
				>
					<LayoutIllustration value={ value } />
					<div className="clp-layout-option__info">
						<span className="clp-layout-option__label">{ label }</span>
						<span className="clp-layout-option__desc">{ description }</span>
					</div>
					{ settings.layout === value && (
						<span className="clp-layout-option__check" aria-hidden="true">✓</span>
					) }
				</button>
			) ) }
		</div>
	);
}
