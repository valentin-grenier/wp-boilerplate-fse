import React from 'react';
import { createRoot } from '@wordpress/element';
import App from './App';
import '../../scss/admin.scss';

const container = document.getElementById('studioval-plugin-boilerplate-app');

if (container) {
	createRoot(container).render(<App />);
}
