import { createElement, createRoot } from '@wordpress/element';
import ThemeOptionsPage from './ThemeOptionPage';

document.addEventListener('DOMContentLoaded', () => {
	const root = document.getElementById('wp-admin-theme-name-theme-options-page__root');

	if (!root) {
		return;
	}

	createRoot(root).render(createElement(ThemeOptionsPage));
});
