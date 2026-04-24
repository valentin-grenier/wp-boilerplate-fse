import React from 'react';
import { TextControl, Button } from '@wordpress/components';
import { MediaUpload, MediaUploadCheck } from '@wordpress/block-editor';
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
		<Card title="Identité visuelle">
			<TextControl
				label="Titre de la page"
				help="Remplace le nom du site affiché au-dessus du formulaire."
				value={ customTitle }
				onChange={ ( val ) => onChange( 'customTitle', val ) }
				placeholder="Mon Site"
			/>

			<div className="clp-field-section">
				<div className="clp-field-label">Logo</div>
				<p className="clp-help">Remplace le logo WordPress par défaut.</p>

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
												Remplacer
											</Button>
											<Button variant="link" isDestructive onClick={ onRemoveLogo }>
												Supprimer
											</Button>
										</div>
									</>
								) : (
									<Button variant="secondary" onClick={ open }>
										Choisir un logo
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
