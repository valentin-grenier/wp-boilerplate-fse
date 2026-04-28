import React from 'react';
import {
	Button,
	Card,
	CardHeader,
	CardBody,
	__experimentalHeading as Heading,
	__experimentalVStack as VStack,
	__experimentalHStack as HStack,
	__experimentalText as Text,
} from '@wordpress/components';
import { MediaUpload, MediaUploadCheck } from '@wordpress/block-editor';
import { __ } from '@wordpress/i18n';

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
		<Card size="small">
			<CardHeader>
				<Heading level={ 3 } size={ 13 }>
					{ __( 'Background image', 'studioval-clp' ) }
				</Heading>
			</CardHeader>
			<CardBody>
				<VStack spacing={ 3 }>
					<Text variant="muted">
						{ __( 'Fills half of the screen. Recommended format: portrait, min 800 × 1000 px.', 'studioval-clp' ) }
					</Text>

					<MediaUploadCheck>
						<MediaUpload
							onSelect={ onSelect }
							allowedTypes={ [ 'image' ] }
							value={ imageId }
							render={ ( { open } ) => (
								<VStack spacing={ 3 }>
									{ imageUrl && (
										<div className="clp-image-preview">
											<img src={ imageUrl } alt="" />
										</div>
									) }
									<HStack spacing={ 2 } justify="flex-start">
										<Button variant="secondary" onClick={ open }>
											{ imageUrl ? __( 'Replace', 'studioval-clp' ) : __( 'Choose an image', 'studioval-clp' ) }
										</Button>
										{ imageUrl && (
											<Button variant="link" isDestructive onClick={ onRemove }>
												{ __( 'Remove', 'studioval-clp' ) }
											</Button>
										) }
									</HStack>
								</VStack>
							) }
						/>
					</MediaUploadCheck>
				</VStack>
			</CardBody>
		</Card>
	);
}
