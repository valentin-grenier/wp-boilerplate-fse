const path = require( 'path' );
const MiniCssExtractPlugin = require( 'mini-css-extract-plugin' );
const DependencyExtractionWebpackPlugin = require( '@wordpress/dependency-extraction-webpack-plugin' );

const isProduction = process.env.NODE_ENV === 'production';

module.exports = {
	mode: isProduction ? 'production' : 'development',
	devtool: isProduction ? false : 'source-map',

	entry: {
		admin: './src/js/admin/index.js',
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
								outputStyle: isProduction
									? 'compressed'
									: 'expanded',
							},
						},
					},
				],
			},
		],
	},

	plugins: [
		new MiniCssExtractPlugin( { filename: '[name].css' } ),
		// Externalises @wordpress/* imports to the wp.* globals shipped by core,
		// and emits an .asset.php manifest per entry point listing the wp script
		// handles each bundle depends on (so wp_enqueue_script gets the right deps).
		new DependencyExtractionWebpackPlugin(),
	],

	resolve: {
		extensions: [ '.js', '.jsx' ],
	},
};
