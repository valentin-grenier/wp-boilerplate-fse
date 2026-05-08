import React from 'react';
import { __experimentalHeading as Heading } from '@wordpress/components';
import { __ } from '@wordpress/i18n';

/**
 * Blank entry point for the plugin admin page.
 *
 * Wire your own state, controls, and REST calls here. The wp-components
 * package is already loaded as a script dependency, so any control
 * (`TextControl`, `ToggleControl`, `Card`, `Button`, …) imports cleanly.
 */
export default function App() {
	return (
		<div className="svpb-admin">
			<Heading level={1} size={20}>
				{__('Plugin Boilerplate', 'studioval-plugin-boilerplate')}
			</Heading>
			<p>
				{__('Replace this scaffold with your plugin UI.', 'studioval-plugin-boilerplate')}
			</p>
		</div>
	);
}
