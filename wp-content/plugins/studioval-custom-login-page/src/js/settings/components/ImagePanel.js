import React from 'react';
import { Button } from '@wordpress/components';
import { MediaUpload, MediaUploadCheck } from '@wordpress/block-editor';
import Card from './Card';

export default function ImagePanel( { settings, onChange } ) {
	const { imageId, imageUrl } = settings;

	const onSelect = ( media ) => {
		onChange( 'imageId', media.id );
		onChange( 'imageUrl', media.url );
	};

	const onRemove = () => {
		onChange( 'imageId', 0 );
		onChange( 'imageUrl', '' );
	};

	return (
		<Card title="Image d'arrière-plan">
			<p className="clp-help">
				Remplit la moitié de l'écran. Format recommandé : portrait, min 800 × 1000 px.
			</p>

			<MediaUploadCheck>
				<MediaUpload
					onSelect={ onSelect }
					allowedTypes={ [ 'image' ] }
					value={ imageId }
					render={ ( { open } ) => (
						<div className="clp-image-control">
							{ imageUrl ? (
								<>
									<div className="clp-image-preview">
										<img src={ imageUrl } alt="" />
									</div>
									<div className="clp-image-actions">
										<Button variant="secondary" onClick={ open }>
											Remplacer
										</Button>
										<Button variant="link" isDestructive onClick={ onRemove }>
											Supprimer
										</Button>
									</div>
								</>
							) : (
								<Button variant="secondary" onClick={ open }>
									Choisir une image
								</Button>
							) }
						</div>
					) }
				/>
			</MediaUploadCheck>
		</Card>
	);
}
