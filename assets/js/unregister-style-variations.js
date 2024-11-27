wp.domReady(function () {
	wp.blocks.unregisterBlockStyle('core/button', ['outline', 'fill']);
	wp.blocks.unregisterBlockStyle('core/image', ['rounded']);
	wp.blocks.unregisterBlockStyle('core/quote', ['plain']);
	wp.blocks.unregisterBlockStyle('core/site-logo', ['rounded']);
	wp.blocks.unregisterBlockStyle('core/separator', ['wide', 'dots']);
	wp.blocks.unregisterBlockStyle('core/social-links', ['pill-shape']);
	wp.blocks.unregisterBlockStyle('core/table', ['stripes']);
	wp.blocks.unregisterBlockStyle('core/tag-cloud', ['outline']);
});
