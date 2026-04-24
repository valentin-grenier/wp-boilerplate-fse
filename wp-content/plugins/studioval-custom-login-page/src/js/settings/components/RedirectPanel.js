import React from 'react';
import { TextControl } from '@wordpress/components';
import Card from './Card';

export default function RedirectPanel( { settings, onChange } ) {
	return (
		<Card title="Redirections">
			<TextControl
				label="Administrateurs et éditeurs"
				help="Laisser vide pour utiliser la valeur par défaut (/wp-admin)."
				type="url"
				value={ settings.redirectAdminUrl }
				onChange={ ( val ) => onChange( 'redirectAdminUrl', val ) }
				placeholder="https://"
			/>

			<TextControl
				label="Tous les autres utilisateurs"
				help="Laisser vide pour utiliser la valeur par défaut."
				type="url"
				value={ settings.redirectUserUrl }
				onChange={ ( val ) => onChange( 'redirectUserUrl', val ) }
				placeholder="https://"
			/>
		</Card>
	);
}
