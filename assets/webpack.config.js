const path = require('path')

module.exports = {
  entry: './js/quetzal_hooks.js',
  output: {
    filename: 'quetzal_hooks.js',
    path: path.resolve(__dirname, '../priv/static'),
    library: 'quetzal',
    libraryTarget: 'umd',
    globalObject: 'this'
  },
  module: {
    rules: [
      {
        test: path.resolve(__dirname, './js/quetzal_hooks.js')
      },
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader'
        }
      }
    ]
  },
  plugins: []
}
