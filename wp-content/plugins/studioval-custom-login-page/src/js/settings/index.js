import React from 'react';
import { render } from '@wordpress/element';
import App from './App';
import '../../scss/settings.scss';

const container = document.getElementById( 'studioval-clp-settings' );

if ( container ) {
	render( <App />, container );
}
