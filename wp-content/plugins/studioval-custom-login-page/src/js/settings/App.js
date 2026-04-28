import React, { useState, useCallback } from 'react';
import apiFetch from '@wordpress/api-fetch';
import {
	Button,
	SnackbarList,
	__experimentalHeading as Heading,
	__experimentalHStack as HStack,
	__experimentalVStack as VStack,
} from '@wordpress/components';
import { __ } from '@wordpress/i18n';
import LayoutPanel from './components/LayoutPanel';
import ColorsPanel from './components/ColorsPanel';
import ImagePanel from './components/ImagePanel';
import BrandingPanel from './components/BrandingPanel';
import FormPanel from './components/FormPanel';
import RedirectPanel from './components/RedirectPanel';

const { settings: initialSettings, defaults, nonce } = window.studiovalClpData;

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
		setNotices( ( prev ) => [ ...prev, { id: String( Date.now() ), content, status } ] );
	}, [] );

	const resetKeys = useCallback( ( keys ) => {
		setSettings( ( prev ) => {
			const next = { ...prev };
			keys.forEach( ( key ) => {
				if ( key in defaults ) {
					next[ key ] = defaults[ key ];
				}
			} );
			return next;
		} );
		addNotice( __( 'Defaults restored — click Save to apply.', 'studioval-clp' ) );
	}, [ addNotice ] );

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
			<VStack spacing={ 5 }>
				<HStack justify="space-between" align="center">
					<Heading level={ 1 } size={ 20 }>
						{ __( 'Custom login', 'studioval-clp' ) }
					</Heading>
					<Button
						variant="primary"
						onClick={ saveSettings }
						isBusy={ isSaving }
						disabled={ isSaving }
						__next40pxDefaultSize
					>
						{ isSaving ? __( 'Saving…', 'studioval-clp' ) : __( 'Save', 'studioval-clp' ) }
					</Button>
				</HStack>

				<LayoutPanel settings={ settings } onChange={ updateSetting } />

				<div className="clp-grid">
					<VStack spacing={ 4 }>
						<ColorsPanel settings={ settings } onChange={ updateSetting } onReset={ resetKeys } />
					</VStack>

					<VStack spacing={ 4 }>
						{ hasImageLayout && (
							<ImagePanel settings={ settings } onChange={ updateSetting } onReset={ resetKeys } />
						) }
						<BrandingPanel settings={ settings } onChange={ updateSetting } onReset={ resetKeys } />
					</VStack>

					<VStack spacing={ 4 }>
						<FormPanel settings={ settings } onChange={ updateSetting } />
						<RedirectPanel settings={ settings } onChange={ updateSetting } />
					</VStack>
				</div>
			</VStack>

			<div className="clp-snackbars">
				<SnackbarList notices={ notices } onRemove={ removeNotice } />
			</div>
		</div>
	);
}
