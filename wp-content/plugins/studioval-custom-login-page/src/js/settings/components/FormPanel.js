import React from 'react';
import { TextControl, ToggleControl } from '@wordpress/components';
import { __ } from '@wordpress/i18n';
import Card from './Card';

export default function FormPanel( { settings, onChange } ) {
	return (
		<Card title={ __( 'Form', 'studioval-clp' ) }>
			<TextControl
				label={ __( 'Button text', 'studioval-clp' ) }
				value={ settings.buttonText }
				onChange={ ( val ) => onChange( 'buttonText', val ) }
				placeholder={ __( 'Log in', 'studioval-clp' ) }
			/>

			<ToggleControl
				label={ __( '"Remember me" checkbox', 'studioval-clp' ) }
				checked={ settings.showRememberMe }
				onChange={ ( val ) => onChange( 'showRememberMe', val ) }
			/>

			<ToggleControl
				label={ __( '"Lost your password?" link', 'studioval-clp' ) }
				checked={ settings.showForgotPassword }
				onChange={ ( val ) => onChange( 'showForgotPassword', val ) }
			/>

			<ToggleControl
				label={ __( '"Back to site" link', 'studioval-clp' ) }
				checked={ settings.showBackToHome }
				onChange={ ( val ) => onChange( 'showBackToHome', val ) }
			/>

			<ToggleControl
				label={ __( 'Generic error messages', 'studioval-clp' ) }
				help={ __( 'Hides whether the username or password is incorrect.', 'studioval-clp' ) }
				checked={ settings.genericErrors }
				onChange={ ( val ) => onChange( 'genericErrors', val ) }
			/>
		</Card>
	);
}
