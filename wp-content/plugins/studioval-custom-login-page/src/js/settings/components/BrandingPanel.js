import React from 'react';
import { TextControl, Button } from '@wordpress/components';
import { MediaUpload, MediaUploadCheck } from '@wordpress/block-editor';
import { __ } from '@wordpress/i18n';
import Card from './Card';

export default function BrandingPanel( { settings, onChange } ) {
	const { logoId, logoUrl, customTitle } = settings;

	const onSelectLogo = ( media ) => {
		onChange( 'logoId', media.id );
		onChange( 'logoUrl', media.url );
	};

	const onRemoveLogo = () => {
		onChange( 'logoId', 0 );
		onChange( 'logoUrl', '' );
	};

	return (
		<Card title={ __( 'Branding', 'studioval-clp' ) }>
			<TextControl
				label={ __( 'Page title', 'studioval-clp' ) }
				help={ __( 'Replaces the site name displayed above the form.', 'studioval-clp' ) }
				value={ customTitle }
				onChange={ ( val ) => onChange( 'customTitle', val ) }
				placeholder={ __( 'My Site', 'studioval-clp' ) }
			/>

			<div className="clp-field-section">
				<div className="clp-field-label">{ __( 'Logo', 'studioval-clp' ) }</div>
				<p className="clp-help">{ __( 'Replaces the default WordPress logo.', 'studioval-clp' ) }</p>

				<MediaUploadCheck>
					<MediaUpload
						onSelect={ onSelectLogo }
						allowedTypes={ [ 'image' ] }
						value={ logoId }
						render={ ( { open } ) => (
							<div className="clp-image-control">
								{ logoUrl ? (
									<>
										<div className="clp-logo-preview">
											<img src={ logoUrl } alt="" />
										</div>
										<div className="clp-image-actions">
											<Button variant="secondary" onClick={ open }>
												{ __( 'Replace', 'studioval-clp' ) }
											</Button>
											<Button variant="link" isDestructive onClick={ onRemoveLogo }>
												{ __( 'Remove', 'studioval-clp' ) }
											</Button>
										</div>
									</>
								) : (
									<Button variant="secondary" onClick={ open }>
										{ __( 'Choose a logo', 'studioval-clp' ) }
									</Button>
								) }
							</div>
						) }
					/>
				</MediaUploadCheck>
			</div>
		</Card>
	);
}
