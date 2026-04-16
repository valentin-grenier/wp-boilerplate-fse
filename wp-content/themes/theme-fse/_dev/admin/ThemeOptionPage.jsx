import { useState, useEffect } from '@wordpress/element';
import { __ } from '@wordpress/i18n';
import apiFetch from '@wordpress/api-fetch';
import { Button, SnackbarList, Spinner } from '@wordpress/components';

import MyCard from './components/MyCard';

const SETTINGS_KEYS = [
	'sarbacane_api_key',
];

const DEFAULT_SETTINGS = {
	sarbacane_api_key: '',
};

export default function ThemeOptionsPage() {
	const [settings, setSettings] = useState(DEFAULT_SETTINGS);
	const [isLoading, setIsLoading] = useState(true);
	const [isSaving, setIsSaving] = useState(false);
	const [notices, setNotices] = useState([]);

	function addNotice(status, message) {
		const id = String(Date.now());
		setNotices((prev) => [...prev, { id, content: message, status }]);
		if (status === 'success') {
			setTimeout(() => setNotices((prev) => prev.filter((n) => n.id !== id)), 3000);
		}
	}

	function removeNotice(id) {
		setNotices((prev) => prev.filter((n) => n.id !== id));
	}

	useEffect(() => {
		apiFetch({ path: '/wp/v2/settings' })
			.then((data) => {
				setSettings((prev) => {
					const next = { ...prev };
					SETTINGS_KEYS.forEach((key) => {
						if (data[key] !== undefined) {
							next[key] = data[key];
						}
					});
					return next;
				});
			})
			.catch(() => {
				addNotice('error', __('Impossible de charger les paramètres.', 'paris'));
			})
			.finally(() => {
				setIsLoading(false);
			});
	}, []);

	function handleChange(key, value) {
		setSettings((prev) => ({ ...prev, [key]: value }));
	}

	function handleSave() {
		setIsSaving(true);

		const payload = {};
		SETTINGS_KEYS.forEach((key) => {
			payload[key] = settings[key];
		});

		apiFetch({
			path: '/wp/v2/settings',
			method: 'POST',
			data: payload,
		})
			.then(() => {
				addNotice('success', __('Paramètres enregistrés.', 'paris'));
			})
			.catch(() => {
				addNotice('error', __("Une erreur est survenue lors de l'enregistrement.", 'paris'));
			})
			.finally(() => {
				setIsSaving(false);
			});
	}

	return (
		<div className="wrap">
			<SnackbarList notices={notices} onRemove={removeNotice} className='wp-admin-theme-name-theme-options-page__snackbar-list' />

			{isLoading ? (
				<Spinner />
			) : (
				<>
					<div className='wp-admin-theme-name-theme-options-page__cards'>
						<MyCard settings={settings} onChange={handleChange} />
					</div>

					<Button variant="primary" onClick={handleSave} isBusy={isSaving} disabled={isSaving} className='wp-admin-theme-name-theme-options-page__submit-button'>
						{__('Enregistrer les modifications', 'theme-name')}
					</Button>
				</>
			)}
		</div>
	);
}
