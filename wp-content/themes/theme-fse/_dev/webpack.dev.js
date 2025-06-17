const path = require('path');
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
				proxy: 'http://wp-boilerplate-fse.local',
				files: ['../**/*.php', '../*.php', '../template-parts/**/*.php', '../**/*.html', '../theme.json', '../acf-json/**/*.json'],
				open: false,
				notify: false,
			},
			{ reload: true }
		),
	],
});
