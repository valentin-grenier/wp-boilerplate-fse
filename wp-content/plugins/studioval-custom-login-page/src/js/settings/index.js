import React from 'react';
import { createRoot } from '@wordpress/element';
import App from './App';
import '../../scss/settings.scss';

const container = document.getElementById( 'studioval-clp-settings' );

if ( container ) {
	createRoot( container ).render( <App /> );
}
