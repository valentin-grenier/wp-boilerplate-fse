import React from 'react';
import {
	TextControl,
	Button,
	Card,
	CardHeader,
	CardBody,
	CardDivider,
	__experimentalHeading as Heading,
	__experimentalVStack as VStack,
	__experimentalHStack as HStack,
	__experimentalText as Text,
} from '@wordpress/components';
import { MediaUpload, MediaUploadCheck } from '@wordpress/block-editor';
import { __ } from '@wordpress/i18n';

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
		<Card size="small">
			<CardHeader>
				<Heading level={ 3 } size={ 13 }>
					{ __( 'Branding', 'studioval-clp' ) }
				</Heading>
			</CardHeader>
			<CardBody>
				<TextControl
					label={ __( 'Page title', 'studioval-clp' ) }
					help={ __( 'Replaces the site name displayed above the form.', 'studioval-clp' ) }
					value={ customTitle }
					onChange={ ( val ) => onChange( 'customTitle', val ) }
					placeholder={ __( 'My Site', 'studioval-clp' ) }
					__nextHasNoMarginBottom
				/>
			</CardBody>

			<CardDivider />

			<CardBody>
				<VStack spacing={ 3 }>
					<VStack spacing={ 1 }>
						<Heading level={ 4 } size={ 11 }>
							{ __( 'Logo', 'studioval-clp' ) }
						</Heading>
						<Text variant="muted">
							{ __( 'Replaces the default WordPress logo.', 'studioval-clp' ) }
						</Text>
					</VStack>

					<MediaUploadCheck>
						<MediaUpload
							onSelect={ onSelectLogo }
							allowedTypes={ [ 'image' ] }
							value={ logoId }
							render={ ( { open } ) => (
								<VStack spacing={ 3 }>
									{ logoUrl && (
										<div className="clp-logo-preview">
											<img src={ logoUrl } alt="" />
										</div>
									) }
									<HStack spacing={ 2 } justify="flex-start">
										<Button variant="secondary" onClick={ open }>
											{ logoUrl ? __( 'Replace', 'studioval-clp' ) : __( 'Choose a logo', 'studioval-clp' ) }
										</Button>
										{ logoUrl && (
											<Button variant="link" isDestructive onClick={ onRemoveLogo }>
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
