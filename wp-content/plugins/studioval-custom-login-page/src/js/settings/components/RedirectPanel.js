import React from 'react';
import { TextControl } from '@wordpress/components';
import { __ } from '@wordpress/i18n';
import Card from './Card';

export default function RedirectPanel( { settings, onChange } ) {
	return (
		<Card title={ __( 'Redirects', 'studioval-clp' ) }>
			<TextControl
				label={ __( 'Administrators and editors', 'studioval-clp' ) }
				help={ __( 'Leave empty to use the default (/wp-admin).', 'studioval-clp' ) }
				type="url"
				value={ settings.redirectAdminUrl }
				onChange={ ( val ) => onChange( 'redirectAdminUrl', val ) }
				placeholder="https://"
			/>

			<TextControl
				label={ __( 'All other users', 'studioval-clp' ) }
				help={ __( 'Leave empty to use the default.', 'studioval-clp' ) }
				type="url"
				value={ settings.redirectUserUrl }
				onChange={ ( val ) => onChange( 'redirectUserUrl', val ) }
				placeholder="https://"
			/>
		</Card>
	);
}
