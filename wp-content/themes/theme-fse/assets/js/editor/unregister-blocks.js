wp.domReady(() => {
	const blocksToUnregister = [
		'core/comments',
		'core/comment-author-name',
		'core/comment-author-avatar',
		'core/comment-content',
		'core/comment-date',
		'core/comment-edit-link',
		'core/comment-reply-link',
		'core/comment-template',
		'core/comments-pagination',
		'core/comments-pagination-next',
		'core/comments-pagination-numbers',
		'core/comments-pagination-previous',
		'core/comments-title',
		'core/post-comments-form',
		'core/latest-comments',
	];

	blocksToUnregister.forEach((block) => {
		if (wp.blocks.getBlockType(block)) {
			wp.blocks.unregisterBlockType(block);
		}
	});
});
