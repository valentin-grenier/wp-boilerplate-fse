import React from 'react';
import { __ } from '@wordpress/i18n';

const LAYOUTS = [
	{
		value: 'basic',
		label: __( 'Basic', 'studioval-clp' ),
		description: __( 'Centered form, solid background', 'studioval-clp' ),
	},
	{
		value: 'image-left',
		label: __( 'Image on the left', 'studioval-clp' ),
		description: __( 'Form on the right', 'studioval-clp' ),
	},
	{
		value: 'image-right',
		label: __( 'Image on the right', 'studioval-clp' ),
		description: __( 'Form on the left', 'studioval-clp' ),
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
