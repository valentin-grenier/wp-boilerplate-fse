const path = require('path');
const glob = require('glob');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

const themeRoot = path.resolve(__dirname, '..');
const devRoot = path.resolve(__dirname);

const blockEntries = {};

// Loop over each block dir (e.g., blocks/my-block/)
glob.sync('blocks/*/', { cwd: devRoot }).forEach((blockFolder) => {
	const blockName = blockFolder.replace(/^blocks\/|\/$/g, ''); // "my-block"
	const entryFiles = [];

	const jsFile = path.join(devRoot, `blocks/${blockName}/block.js`);
	const scssFile = path.join(devRoot, `blocks/${blockName}/block.scss`);

	if (glob.sync(jsFile).length) entryFiles.push(jsFile);
	if (glob.sync(scssFile).length) entryFiles.push(scssFile);

	if (entryFiles.length) {
		blockEntries[`blocks/${blockName}`] = entryFiles;
	}
});

module.exports = {
	entry: {
		theme: ['./js/theme.js', './scss/theme.scss'],
		...blockEntries,
	},
	output: {
		filename: ({ chunk }) => {
			if (chunk.name.startsWith('blocks/')) {
				const [, blockName] = chunk.name.split('/');
				return `blocks/${blockName}/block.js`;
			}
			return 'js/[name].bundle.js';
		},
		path: path.resolve(__dirname, '../dist'),
		clean: true,
	},
	module: {
		rules: [
			{
				test: /\.js$/,
				exclude: /node_modules/,
				use: ['babel-loader'],
			},
			{
				test: /\.(scss|css)$/,
				use: [MiniCssExtractPlugin.loader, 'css-loader', 'postcss-loader', 'sass-loader'],
			},
		],
	},
	resolve: {
		extensions: ['.js', '.scss'],
	},
	plugins: [
		new MiniCssExtractPlugin({
			filename: ({ chunk }) => {
				if (chunk.name.startsWith('blocks/')) {
					const [, blockName] = chunk.name.split('/');
					return `blocks/${blockName}/block.css`;
				}
				return `css/${chunk.name}.css`;
			},
		}),
	],
};
