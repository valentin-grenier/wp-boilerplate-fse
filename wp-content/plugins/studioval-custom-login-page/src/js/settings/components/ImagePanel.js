import React from 'react';
import { Button } from '@wordpress/components';
import { MediaUpload, MediaUploadCheck } from '@wordpress/block-editor';
import { __ } from '@wordpress/i18n';
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
		<Card title={ __( 'Background image', 'studioval-clp' ) }>
			<p className="clp-help">
				{ __( 'Fills half of the screen. Recommended format: portrait, min 800 × 1000 px.', 'studioval-clp' ) }
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
											{ __( 'Replace', 'studioval-clp' ) }
										</Button>
										<Button variant="link" isDestructive onClick={ onRemove }>
											{ __( 'Remove', 'studioval-clp' ) }
										</Button>
									</div>
								</>
							) : (
								<Button variant="secondary" onClick={ open }>
									{ __( 'Choose an image', 'studioval-clp' ) }
								</Button>
							) }
						</div>
					) }
				/>
			</MediaUploadCheck>
		</Card>
	);
}
