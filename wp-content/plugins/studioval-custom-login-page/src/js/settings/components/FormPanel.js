import React from 'react';
import { TextControl, ToggleControl } from '@wordpress/components';
import Card from './Card';

export default function FormPanel( { settings, onChange } ) {
	return (
		<Card title="Formulaire">
			<TextControl
				label="Texte du bouton"
				value={ settings.buttonText }
				onChange={ ( val ) => onChange( 'buttonText', val ) }
				placeholder="Se connecter"
			/>

			<ToggleControl
				label='Case "Se souvenir de moi"'
				checked={ settings.showRememberMe }
				onChange={ ( val ) => onChange( 'showRememberMe', val ) }
			/>

			<ToggleControl
				label='Lien "Mot de passe oublié ?"'
				checked={ settings.showForgotPassword }
				onChange={ ( val ) => onChange( 'showForgotPassword', val ) }
			/>

			<ToggleControl
				label='Lien "Retour au site"'
				checked={ settings.showBackToHome }
				onChange={ ( val ) => onChange( 'showBackToHome', val ) }
			/>

			<ToggleControl
				label="Messages d'erreur génériques"
				help="Ne révèle pas si c'est l'identifiant ou le mot de passe qui est incorrect."
				checked={ settings.genericErrors }
				onChange={ ( val ) => onChange( 'genericErrors', val ) }
			/>
		</Card>
	);
}
