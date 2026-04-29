const path = require('path');
const glob = require('glob');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const CopyPlugin = require('copy-webpack-plugin');

const themeRoot = path.resolve(__dirname, '..');
const devRoot = path.resolve(__dirname);

// Per block, discover up to four files and produce up to three entries:
//   blocks/{name}/block          ← {name}.js + {name}.scss          → block.js + block.css
//   blocks/{name}/block-editor   ← {name}-editor.scss               → block-editor.css
//   blocks/{name}/block-frontend ← {name}-frontend.js               → block-frontend.js
const blockEntries = {};

glob.sync('blocks/*/', { cwd: devRoot }).forEach((blockFolder) => {
	const blockName = blockFolder.replace(/^blocks\/|\/$/g, '');
	const blockDir = path.join(devRoot, 'blocks', blockName);

	const mainJs = path.join(blockDir, `${blockName}.js`);
	const mainScss = path.join(blockDir, `${blockName}.scss`);
	const editorScss = path.join(blockDir, `${blockName}-editor.scss`);
	const frontendJs = path.join(blockDir, `${blockName}-frontend.js`);

	const main = [];
	if (glob.sync(mainJs).length) main.push(mainJs);
	if (glob.sync(mainScss).length) main.push(mainScss);
	if (main.length) {
		blockEntries[`blocks/${blockName}/block`] = main;
	}

	if (glob.sync(editorScss).length) {
		blockEntries[`blocks/${blockName}/block-editor`] = [editorScss];
	}

	if (glob.sync(frontendJs).length) {
		blockEntries[`blocks/${blockName}/block-frontend`] = [frontendJs];
	}
});

module.exports = {
	entry: {
		theme: ['./js/theme.js', './scss/theme.scss'],
		editor: ['./js/editor.js', './scss/editor.scss'],
		admin: ['./admin/admin.js', './scss/admin.scss'],
		...blockEntries,
	},
	externals: {
		'@wordpress/blocks': ['wp', 'blocks'],
		'@wordpress/block-editor': ['wp', 'blockEditor'],
		'@wordpress/element': ['wp', 'element'],
		'@wordpress/i18n': ['wp', 'i18n'],
		'@wordpress/api-fetch': ['wp', 'apiFetch'],
		'@wordpress/components': ['wp', 'components'],
	},
	output: {
		filename: ({ chunk }) => {
			if (chunk.name.startsWith('blocks/')) {
				return `${chunk.name}.js`;
			}
			return 'js/[name].bundle.js';
		},
		path: path.resolve(__dirname, '../dist'),
		clean: true,
	},
	module: {
		rules: [
			{
				test: /\.(js|jsx)$/,
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
		extensions: ['.js', '.jsx', '.scss'],
	},
	plugins: [
		new MiniCssExtractPlugin({
			filename: ({ chunk }) => {
				if (chunk.name.startsWith('blocks/')) {
					return `${chunk.name}.css`;
				}
				return `css/${chunk.name}.css`;
			},
		}),
		new CopyPlugin({
			patterns: [
				{
					from: path.resolve(devRoot, 'assets/theme'),
					to: path.resolve(themeRoot, 'dist/assets/theme'),
				},
			],
		}),
	],
};
