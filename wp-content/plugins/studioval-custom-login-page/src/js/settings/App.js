import React, { useState, useCallback } from 'react';
import apiFetch from '@wordpress/api-fetch';
import { Button, SnackbarList } from '@wordpress/components';
import { __ } from '@wordpress/i18n';
import LayoutPanel from './components/LayoutPanel';
import ColorsPanel from './components/ColorsPanel';
import ImagePanel from './components/ImagePanel';
import BrandingPanel from './components/BrandingPanel';
import FormPanel from './components/FormPanel';
import RedirectPanel from './components/RedirectPanel';

const { settings: initialSettings, nonce } = window.studiovalClpData;

apiFetch.use( apiFetch.createNonceMiddleware( nonce ) );

export default function App() {
	const [ settings, setSettings ] = useState( initialSettings );
	const [ isSaving, setIsSaving ]  = useState( false );
	const [ notices, setNotices ]    = useState( [] );

	const updateSetting = useCallback( ( key, value ) => {
		setSettings( ( prev ) => ( { ...prev, [ key ]: value } ) );
	}, [] );

	const removeNotice = useCallback( ( id ) => {
		setNotices( ( prev ) => prev.filter( ( n ) => n.id !== id ) );
	}, [] );

	const addNotice = useCallback( ( content, status = 'success' ) => {
		// SnackbarList handles auto-dismiss internally via onRemove.
		setNotices( ( prev ) => [ ...prev, { id: String( Date.now() ), content, status } ] );
	}, [] );

	const saveSettings = async () => {
		setIsSaving( true );
		try {
			const updated = await apiFetch( {
				path: '/wp/v2/settings',
				method: 'POST',
				data: { studioval_clp_settings: settings },
			} );

			if ( updated?.studioval_clp_settings ) {
				setSettings( updated.studioval_clp_settings );
			}

			addNotice( __( 'Settings saved.', 'studioval-clp' ) );
		} catch ( error ) {
			addNotice(
				error?.message || __( 'An error occurred while saving.', 'studioval-clp' ),
				'error'
			);
		} finally {
			setIsSaving( false );
		}
	};

	const hasImageLayout = [ 'image-left', 'image-right' ].includes( settings.layout );

	return (
		<div className="clp-settings-wrap">
			<div className="clp-settings-header">
				<h1 className="clp-settings-title">{ __( 'Custom login', 'studioval-clp' ) }</h1>
				<Button
					variant="primary"
					onClick={ saveSettings }
					isBusy={ isSaving }
					disabled={ isSaving }
				>
					{ isSaving ? __( 'Saving…', 'studioval-clp' ) : __( 'Save', 'studioval-clp' ) }
				</Button>
			</div>

			<LayoutPanel settings={ settings } onChange={ updateSetting } />

			<div className="clp-grid">
				<div className="clp-grid__col">
					<ColorsPanel settings={ settings } onChange={ updateSetting } />
				</div>

				<div className="clp-grid__col">
					{ hasImageLayout && (
						<ImagePanel settings={ settings } onChange={ updateSetting } />
					) }
					<BrandingPanel settings={ settings } onChange={ updateSetting } />
				</div>

				<div className="clp-grid__col">
					<FormPanel settings={ settings } onChange={ updateSetting } />
					<RedirectPanel settings={ settings } onChange={ updateSetting } />
				</div>
			</div>

			<div className="clp-snackbars">
				<SnackbarList notices={ notices } onRemove={ removeNotice } />
			</div>
		</div>
	);
}
