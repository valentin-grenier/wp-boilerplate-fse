const { merge } = require('webpack-merge');
const common = require('./webpack.common.js');
const BrowserSyncPlugin = require('browser-sync-webpack-plugin');

module.exports = merge(common, {
	mode: 'development',
	watch: true,
	devtool: 'source-map',
	plugins: [
		new BrowserSyncPlugin(
			{
				proxy: 'http://wp-boilerplate-fse.local', // 👈 Change to your local WP domain
				files: ['../**/*.php', '../*.php', '../template-parts/**/*.php', '../**/*.html', '../theme.json', '../acf-json/**/*.json'],
				open: false, // Prevent BrowserSync from opening a new tab
				notify: false, // Disable the BrowserSync popup
			},
			{
				reload: true, // Reload on any non-CSS/JS change
			}
		),
	],
});
