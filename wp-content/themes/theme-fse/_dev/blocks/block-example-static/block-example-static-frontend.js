document.addEventListener('DOMContentLoaded', () => {
	const blocks = document.querySelectorAll('.wp-block-studioval-block-example-static');

	blocks.forEach((block) => {
		// eslint-disable-next-line no-console
		console.log('Block Example Static block initialized', block);
	});
});
