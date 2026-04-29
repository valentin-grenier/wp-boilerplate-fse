import { __ } from '@wordpress/i18n';
import { Card, CardHeader, CardBody, CardDivider, Flex, TextControl } from '@wordpress/components';

export default function StickyButtonCard({ settings, onChange }) {
	return (
		<Card className="wp-admin-theme-name-theme-options-page__card">
			<CardHeader className="wp-admin-theme-name-theme-options-page__card-header">
				<h2 className="wp-admin-theme-name-theme-options-page__card-header-title">{__("Carte d'exemple", 'theme-name')}</h2>
			</CardHeader>
			<CardDivider />
			<CardBody className="wp-admin-theme-name-theme-options-page__card-body">
				<Flex direction="column" gap={4}>
					<TextControl label={__('Label', 'theme-name')} help={__("Texte d'aide", 'theme-name')} value={settings.sarbacane_api_key} onChange={(val) => onChange('sarbacane_api_key', val)} __next40pxDefaultSize __nextHasNoMarginBottom/>
				</Flex>
			</CardBody>
		</Card>
	);
}
