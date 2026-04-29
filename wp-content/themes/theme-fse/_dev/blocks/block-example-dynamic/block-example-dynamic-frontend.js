document.addEventListener('DOMContentLoaded', () => {
	const blocks = document.querySelectorAll('.wp-block-studioval-block-example-dynamic');

	blocks.forEach((block) => {
		// eslint-disable-next-line no-console
		console.log('Block Example Dynamic block initialized', block);
	});
});
