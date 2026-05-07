/**
 * Frontend banner — vanilla JS.
 *
 * Wires the close button to hide the banner and remember the choice in
 * localStorage so it doesn't reappear on the next page load. Intentionally no
 * framework, no jQuery — runs ~immediately after parse.
 */

import '../scss/frontend.scss';

const STORAGE_KEY = 'svpb_banner_dismissed_at';
const TTL_MS = 24 * 60 * 60 * 1000; // 1 day.

function isRecentlyDismissed() {
	try {
		const raw = window.localStorage.getItem(STORAGE_KEY);
		if (!raw) {
			return false;
		}
		return Date.now() - Number(raw) < TTL_MS;
	} catch {
		return false;
	}
}

function dismiss(banner) {
	banner.classList.add('is-hidden');
	try {
		window.localStorage.setItem(STORAGE_KEY, String(Date.now()));
	} catch {
		// Storage may be unavailable (private mode, quota); fail silently.
	}
}

function init() {
	const banner = document.querySelector('.svpb-banner');
	if (!banner) {
		return;
	}

	if (isRecentlyDismissed()) {
		banner.classList.add('is-hidden');
		return;
	}

	const closeButton = banner.querySelector('.svpb-banner__close');
	if (closeButton) {
		closeButton.addEventListener('click', () => dismiss(banner));
	}
}

if (document.readyState === 'loading') {
	document.addEventListener('DOMContentLoaded', init);
} else {
	init();
}
