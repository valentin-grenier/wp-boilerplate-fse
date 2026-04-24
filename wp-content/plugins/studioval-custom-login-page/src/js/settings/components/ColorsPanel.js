import React from 'react';
import { ColorPalette, ColorPicker, Dropdown, RangeControl } from '@wordpress/components';
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
		<Card title="Couleurs">
			<ColorControl
				label="Arrière-plan de la page"
				value={ settings.bgColor }
				onChange={ ( val ) => onChange( 'bgColor', val ) }
			/>
			<ColorControl
				label="Arrière-plan du formulaire"
				value={ settings.formBgColor }
				onChange={ ( val ) => onChange( 'formBgColor', val ) }
			/>
			<ColorControl
				label="Texte"
				value={ settings.textColor }
				onChange={ ( val ) => onChange( 'textColor', val ) }
			/>
			<ColorControl
				label="Fond du bouton"
				value={ settings.buttonBgColor }
				onChange={ ( val ) => onChange( 'buttonBgColor', val ) }
			/>
			<ColorControl
				label="Texte du bouton"
				value={ settings.buttonTextColor }
				onChange={ ( val ) => onChange( 'buttonTextColor', val ) }
			/>
			<ColorControl
				label="Liens"
				value={ settings.linkColor }
				onChange={ ( val ) => onChange( 'linkColor', val ) }
			/>

			{ hasImageLayout && (
				<>
					<div className="clp-separator" />
					<ColorControl
						label="Superposition (image)"
						value={ settings.overlayColor }
						onChange={ ( val ) => onChange( 'overlayColor', val ) }
					/>
					<div className="clp-range-wrap">
						<RangeControl
							label={ `Opacité — ${ Math.round( settings.overlayOpacity * 100 ) } %` }
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
