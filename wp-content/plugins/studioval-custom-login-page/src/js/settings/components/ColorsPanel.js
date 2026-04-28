import React from 'react';
import {
	ColorPalette,
	ColorPicker,
	ColorIndicator,
	Dropdown,
	RangeControl,
	Card,
	CardHeader,
	CardBody,
	CardDivider,
	Button,
	Flex,
	FlexItem,
	__experimentalHeading as Heading,
	__experimentalVStack as VStack,
	__experimentalText as Text,
} from '@wordpress/components';
import { __, sprintf } from '@wordpress/i18n';

const palette = window.studiovalClpData?.palette ?? [];
const hasPalette = palette.length > 0;

function ColorControl( { label, value, onChange } ) {
	return (
		<Flex justify="space-between" align="center">
			<FlexItem>
				<Text>{ label }</Text>
			</FlexItem>
			<FlexItem>
				<Dropdown
					popoverProps={ { placement: 'bottom-end' } }
					renderToggle={ ( { isOpen, onToggle } ) => (
						<Button
							variant="tertiary"
							size="small"
							onClick={ onToggle }
							aria-expanded={ isOpen }
						>
							<Flex gap={ 2 } align="center" expanded={ false }>
								<ColorIndicator colorValue={ value } />
								<Text variant="muted" size={ 11 }>
									{ value || '—' }
								</Text>
							</Flex>
						</Button>
					) }
					renderContent={ () => (
						<div style={ { padding: 8, minWidth: 200 } }>
							{ hasPalette ? (
								<ColorPalette
									colors={ palette }
									value={ value }
									onChange={ ( val ) => val && onChange( val ) }
									disableCustomColors
									clearable={ false }
									__experimentalIsRenderedInSidebar
								/>
							) : (
								<ColorPicker
									color={ value }
									onChange={ onChange }
									enableAlpha={ false }
								/>
							) }
						</div>
					) }
				/>
			</FlexItem>
		</Flex>
	);
}

export default function ColorsPanel( { settings, onChange } ) {
	const hasImageLayout = [ 'image-left', 'image-right' ].includes( settings.layout );

	return (
		<Card size="small">
			<CardHeader>
				<Heading level={ 3 } size={ 13 }>
					{ __( 'Colors', 'studioval-clp' ) }
				</Heading>
			</CardHeader>
			<CardBody>
				<VStack spacing={ 3 }>
					<ColorControl
						label={ __( 'Page background', 'studioval-clp' ) }
						value={ settings.bgColor }
						onChange={ ( val ) => onChange( 'bgColor', val ) }
					/>
					<ColorControl
						label={ __( 'Form background', 'studioval-clp' ) }
						value={ settings.formBgColor }
						onChange={ ( val ) => onChange( 'formBgColor', val ) }
					/>
					<ColorControl
						label={ __( 'Text', 'studioval-clp' ) }
						value={ settings.textColor }
						onChange={ ( val ) => onChange( 'textColor', val ) }
					/>
					<ColorControl
						label={ __( 'Button background', 'studioval-clp' ) }
						value={ settings.buttonBgColor }
						onChange={ ( val ) => onChange( 'buttonBgColor', val ) }
					/>
					<ColorControl
						label={ __( 'Button text', 'studioval-clp' ) }
						value={ settings.buttonTextColor }
						onChange={ ( val ) => onChange( 'buttonTextColor', val ) }
					/>
					<ColorControl
						label={ __( 'Links', 'studioval-clp' ) }
						value={ settings.linkColor }
						onChange={ ( val ) => onChange( 'linkColor', val ) }
					/>
				</VStack>
			</CardBody>

			{ hasImageLayout && (
				<>
					<CardDivider />
					<CardBody>
						<VStack spacing={ 4 }>
							<ColorControl
								label={ __( 'Image overlay', 'studioval-clp' ) }
								value={ settings.overlayColor }
								onChange={ ( val ) => onChange( 'overlayColor', val ) }
							/>
							<RangeControl
								label={ sprintf(
									/* translators: %d: opacity percentage. */
									__( 'Opacity — %d %%', 'studioval-clp' ),
									Math.round( settings.overlayOpacity * 100 )
								) }
								value={ Math.round( settings.overlayOpacity * 100 ) }
								onChange={ ( val ) => onChange( 'overlayOpacity', val / 100 ) }
								min={ 0 }
								max={ 100 }
								step={ 5 }
								__nextHasNoMarginBottom
								__next40pxDefaultSize
							/>
						</VStack>
					</CardBody>
				</>
			) }
		</Card>
	);
}
