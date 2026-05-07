import React, { useState, useCallback } from 'react';
import apiFetch from '@wordpress/api-fetch';
import {
	Button,
	Card,
	CardBody,
	CardHeader,
	ColorPalette,
	Notice,
	SelectControl,
	SnackbarList,
	TextControl,
	ToggleControl,
	__experimentalHeading as Heading,
	__experimentalHStack as HStack,
	__experimentalVStack as VStack,
} from '@wordpress/components';
import { __ } from '@wordpress/i18n';

const {
	settings: initialSettings,
	defaults,
	nonce,
	optionName,
} = window.studiovalPluginBoilerplateData;

apiFetch.use(apiFetch.createNonceMiddleware(nonce));

const COLOR_PRESETS = [
	{ name: __('Black', 'studioval-plugin-boilerplate'), color: '#1d2327' },
	{ name: __('White', 'studioval-plugin-boilerplate'), color: '#ffffff' },
	{ name: __('Blue', 'studioval-plugin-boilerplate'), color: '#2271b1' },
	{ name: __('Red', 'studioval-plugin-boilerplate'), color: '#d63638' },
	{ name: __('Green', 'studioval-plugin-boilerplate'), color: '#00a32a' },
];

export default function App() {
	const [settings, setSettings] = useState(initialSettings);
	const [isSaving, setIsSaving] = useState(false);
	const [notices, setNotices] = useState([]);

	const update = useCallback((key, value) => {
		setSettings((prev) => ({ ...prev, [key]: value }));
	}, []);

	const removeNotice = useCallback((id) => {
		setNotices((prev) => prev.filter((n) => n.id !== id));
	}, []);

	const addNotice = useCallback((content, status = 'success') => {
		setNotices((prev) => [
			...prev,
			{ id: String(Date.now() + Math.random()), content, status },
		]);
	}, []);

	const reset = useCallback(() => {
		setSettings(defaults);
		addNotice(__('Defaults restored — click Save to apply.', 'studioval-plugin-boilerplate'));
	}, [addNotice]);

	const save = async () => {
		setIsSaving(true);
		try {
			const updated = await apiFetch({
				path: '/wp/v2/settings',
				method: 'POST',
				data: { [optionName]: settings },
			});

			if (updated?.[optionName]) {
				setSettings(updated[optionName]);
			}

			addNotice(__('Settings saved.', 'studioval-plugin-boilerplate'));
		} catch (error) {
			addNotice(
				error?.message ||
					__('An error occurred while saving.', 'studioval-plugin-boilerplate'),
				'error'
			);
		} finally {
			setIsSaving(false);
		}
	};

	return (
		<div className="svpb-settings">
			<VStack spacing={5}>
				<HStack justify="space-between" align="center">
					<Heading level={1} size={20}>
						{__('Plugin Boilerplate', 'studioval-plugin-boilerplate')}
					</Heading>
					<HStack spacing={2} justify="flex-end" expanded={false}>
						<Button
							variant="tertiary"
							onClick={reset}
							disabled={isSaving}
							__next40pxDefaultSize
						>
							{__('Reset', 'studioval-plugin-boilerplate')}
						</Button>
						<Button
							variant="primary"
							onClick={save}
							isBusy={isSaving}
							disabled={isSaving}
							__next40pxDefaultSize
						>
							{isSaving
								? __('Saving…', 'studioval-plugin-boilerplate')
								: __('Save', 'studioval-plugin-boilerplate')}
						</Button>
					</HStack>
				</HStack>

				<Notice status="info" isDismissible={false}>
					{__(
						'Boilerplate demo: a frontend banner driven by these settings. Replace with your own controls.',
						'studioval-plugin-boilerplate'
					)}
				</Notice>

				<Card>
					<CardHeader>
						<Heading level={2} size={16}>
							{__('Banner content', 'studioval-plugin-boilerplate')}
						</Heading>
					</CardHeader>
					<CardBody>
						<VStack spacing={4}>
							<ToggleControl
								__nextHasNoMarginBottom
								label={__('Enable banner', 'studioval-plugin-boilerplate')}
								help={__(
									'When enabled, the banner is rendered on every front-end page.',
									'studioval-plugin-boilerplate'
								)}
								checked={!!settings.enabled}
								onChange={(v) => update('enabled', v)}
							/>

							<TextControl
								__nextHasNoMarginBottom
								__next40pxDefaultSize
								label={__('Message', 'studioval-plugin-boilerplate')}
								value={settings.message ?? ''}
								onChange={(v) => update('message', v)}
							/>

							<SelectControl
								__nextHasNoMarginBottom
								__next40pxDefaultSize
								label={__('Position', 'studioval-plugin-boilerplate')}
								value={settings.position ?? 'top'}
								options={[
									{
										label: __('Top of page', 'studioval-plugin-boilerplate'),
										value: 'top',
									},
									{
										label: __('Bottom of page', 'studioval-plugin-boilerplate'),
										value: 'bottom',
									},
								]}
								onChange={(v) => update('position', v)}
							/>

							<ToggleControl
								__nextHasNoMarginBottom
								label={__('Show dismiss button', 'studioval-plugin-boilerplate')}
								checked={!!settings.dismissible}
								onChange={(v) => update('dismissible', v)}
							/>
						</VStack>
					</CardBody>
				</Card>

				<HStack align="flex-start" spacing={4} alignment="stretch">
					<Card style={{ flex: 1 }}>
						<CardHeader>
							<Heading level={2} size={16}>
								{__('Background color', 'studioval-plugin-boilerplate')}
							</Heading>
						</CardHeader>
						<CardBody>
							<ColorPalette
								colors={COLOR_PRESETS}
								value={settings.bgColor ?? ''}
								onChange={(v) => update('bgColor', v || defaults.bgColor)}
								enableAlpha={false}
								clearable={false}
							/>
						</CardBody>
					</Card>

					<Card style={{ flex: 1 }}>
						<CardHeader>
							<Heading level={2} size={16}>
								{__('Text color', 'studioval-plugin-boilerplate')}
							</Heading>
						</CardHeader>
						<CardBody>
							<ColorPalette
								colors={COLOR_PRESETS}
								value={settings.textColor ?? ''}
								onChange={(v) => update('textColor', v || defaults.textColor)}
								enableAlpha={false}
								clearable={false}
							/>
						</CardBody>
					</Card>
				</HStack>
			</VStack>

			<div className="svpb-snackbars">
				<SnackbarList notices={notices} onRemove={removeNotice} />
			</div>
		</div>
	);
}
