import React from 'react';
import { ColorPalette, ColorPicker, Dropdown, RangeControl } from '@wordpress/components';
import { __, sprintf } from '@wordpress/i18n';
import Card from './Card';

const palette = window.studiovalClpData?.palette ?? [];
const hasPalette = palette.length > 0;

function ColorControl( { label, value, onChange } ) {
	return (
		<div className="clp-color-row">
			<span className="clp-color-row__label">{ label }</span>
			<Dropdown
				contentClassName="clp-color-popover"
				renderToggle={ ( { isOpen, onToggle } ) => (
					<button
						type="button"
						className={ `clp-color-trigger${ isOpen ? ' is-open' : '' }` }
						onClick={ onToggle }
						aria-expanded={ isOpen }
					>
						<span
							className="clp-color-swatch"
							style={ { backgroundColor: value || 'transparent' } }
						/>
						<span className="clp-color-hex">{ value || '—' }</span>
					</button>
				) }
				renderContent={ () =>
					hasPalette ? (
						<ColorPalette
							colors={ palette }
							value={ value }
							onChange={ ( val ) => val && onChange( val ) }
							disableCustomColors
							clearable={ false }
						/>
					) : (
						<ColorPicker
							color={ value }
							onChange={ onChange }
							enableAlpha={ false }
						/>
					)
				}
			/>
		</div>
	);
}

export default function ColorsPanel( { settings, onChange } ) {
	const hasImageLayout = [ 'image-left', 'image-right' ].includes( settings.layout );

	return (
		<Card title={ __( 'Colors', 'studioval-clp' ) }>
			<ColorControl
				label={ __( 'Page background', 'studioval-clp' ) }
				value={ settings.bgColor }
				onChange={ ( val ) => onChange( 'bgColor', val ) }
			/>
			<ColorControl
				label={ __( 'Form background', 'studioval-clp' ) }
				value={ settings.formBgColor }
				onChange={ ( val ) => onChange( 'formBgColor', val ) }
			/>
			<ColorControl
				label={ __( 'Text', 'studioval-clp' ) }
				value={ settings.textColor }
				onChange={ ( val ) => onChange( 'textColor', val ) }
			/>
			<ColorControl
				label={ __( 'Button background', 'studioval-clp' ) }
				value={ settings.buttonBgColor }
				onChange={ ( val ) => onChange( 'buttonBgColor', val ) }
			/>
			<ColorControl
				label={ __( 'Button text', 'studioval-clp' ) }
				value={ settings.buttonTextColor }
				onChange={ ( val ) => onChange( 'buttonTextColor', val ) }
			/>
			<ColorControl
				label={ __( 'Links', 'studioval-clp' ) }
				value={ settings.linkColor }
				onChange={ ( val ) => onChange( 'linkColor', val ) }
			/>

			{ hasImageLayout && (
				<>
					<div className="clp-separator" />
					<ColorControl
						label={ __( 'Image overlay', 'studioval-clp' ) }
						value={ settings.overlayColor }
						onChange={ ( val ) => onChange( 'overlayColor', val ) }
					/>
					<div className="clp-range-wrap">
						<RangeControl
							label={ sprintf(
								/* translators: %d: opacity percentage. */
								__( 'Opacity — %d %%', 'studioval-clp' ),
								Math.round( settings.overlayOpacity * 100 )
							) }
							value={ Math.round( settings.overlayOpacity * 100 ) }
							onChange={ ( val ) => onChange( 'overlayOpacity', val / 100 ) }
							min={ 0 }
							max={ 100 }
							step={ 5 }
						/>
					</div>
				</>
			) }
		</Card>
	);
}
