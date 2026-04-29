const path = require( 'path' );
const MiniCssExtractPlugin = require( 'mini-css-extract-plugin' );
const DependencyExtractionWebpackPlugin = require( '@wordpress/dependency-extraction-webpack-plugin' );

const isProduction = process.env.NODE_ENV === 'production';

module.exports = {
	mode: isProduction ? 'production' : 'development',
	devtool: isProduction ? false : 'source-map',

	entry: {
		settings: './src/js/settings/index.js',
		login: './src/js/login.js',
	},

	output: {
		path: path.resolve( __dirname, 'dist' ),
		filename: '[name].js',
		clean: true,
	},

	module: {
		rules: [
			{
				test: /\.jsx?$/,
				exclude: /node_modules/,
				use: 'babel-loader',
			},
			{
				test: /\.scss$/,
				use: [
					MiniCssExtractPlugin.loader,
					'css-loader',
					{
						loader: 'sass-loader',
						options: {
							api: 'modern',
							sassOptions: {
								outputStyle: isProduction ? 'compressed' : 'expanded',
							},
						},
					},
				],
			},
		],
	},

	plugins: [
		new MiniCssExtractPlugin( { filename: '[name].css' } ),
		new DependencyExtractionWebpackPlugin(),
	],

	resolve: {
		extensions: [ '.js', '.jsx' ],
	},
};
