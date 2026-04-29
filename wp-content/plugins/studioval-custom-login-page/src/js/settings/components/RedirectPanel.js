import React from 'react';
import { TextControl, Card, CardHeader, CardBody, __experimentalHeading as Heading, __experimentalVStack as VStack } from '@wordpress/components';
import { __ } from '@wordpress/i18n';

export default function RedirectPanel( { settings, onChange } ) {
	return (
		<Card size="small">
			<CardHeader>
				<Heading level={ 3 } size={ 13 }>
					{ __( 'Redirects', 'studioval-clp' ) }
				</Heading>
			</CardHeader>
			<CardBody>
				<VStack spacing={ 4 }>
					<TextControl
						label={ __( 'Administrators and editors', 'studioval-clp' ) }
						help={ __( 'Leave empty to use the default (/wp-admin).', 'studioval-clp' ) }
						type="url"
						value={ settings.redirectAdminUrl }
						onChange={ ( val ) => onChange( 'redirectAdminUrl', val ) }
						placeholder="https://"
						__nextHasNoMarginBottom
					/>

					<TextControl
						label={ __( 'All other users', 'studioval-clp' ) }
						help={ __( 'Leave empty to use the default.', 'studioval-clp' ) }
						type="url"
						value={ settings.redirectUserUrl }
						onChange={ ( val ) => onChange( 'redirectUserUrl', val ) }
						placeholder="https://"
						__nextHasNoMarginBottom
					/>
				</VStack>
			</CardBody>
		</Card>
	);
}
