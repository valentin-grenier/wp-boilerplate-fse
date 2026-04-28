import React from 'react';
import { TextControl, ToggleControl, Card, CardHeader, CardBody, __experimentalHeading as Heading, __experimentalVStack as VStack } from '@wordpress/components';
import { __ } from '@wordpress/i18n';

export default function FormPanel( { settings, onChange } ) {
	return (
		<Card size="small">
			<CardHeader>
				<Heading level={ 3 } size={ 13 }>
					{ __( 'Form', 'studioval-clp' ) }
				</Heading>
			</CardHeader>
			<CardBody>
				<VStack spacing={ 4 }>
					<TextControl
						label={ __( 'Button text', 'studioval-clp' ) }
						value={ settings.buttonText }
						onChange={ ( val ) => onChange( 'buttonText', val ) }
						placeholder={ __( 'Log in', 'studioval-clp' ) }
						__nextHasNoMarginBottom
					/>

					<ToggleControl
						label={ __( '"Remember me" checkbox', 'studioval-clp' ) }
						checked={ settings.showRememberMe }
						onChange={ ( val ) => onChange( 'showRememberMe', val ) }
						__nextHasNoMarginBottom
					/>

					<ToggleControl
						label={ __( '"Lost your password?" link', 'studioval-clp' ) }
						checked={ settings.showForgotPassword }
						onChange={ ( val ) => onChange( 'showForgotPassword', val ) }
						__nextHasNoMarginBottom
					/>

					<ToggleControl
						label={ __( '"Back to site" link', 'studioval-clp' ) }
						checked={ settings.showBackToHome }
						onChange={ ( val ) => onChange( 'showBackToHome', val ) }
						__nextHasNoMarginBottom
					/>

					<ToggleControl
						label={ __( 'Generic error messages', 'studioval-clp' ) }
						help={ __( 'Hides whether the username or password is incorrect.', 'studioval-clp' ) }
						checked={ settings.genericErrors }
						onChange={ ( val ) => onChange( 'genericErrors', val ) }
						__nextHasNoMarginBottom
					/>
				</VStack>
			</CardBody>
		</Card>
	);
}
