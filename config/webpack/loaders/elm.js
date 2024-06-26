const { resolve } = require('path');

const isProduction = process.env.NODE_ENV === 'production';
const isPi = process.env.RAILS_ENV === 'pi';
const isDevelopment = process.env.NODE_ENV === 'development';
const elmSource = resolve(process.cwd());
let elmBinary;

if (isPi) {
  elmBinary = `/usr/local/bin/elm`;
} else {
  elmBinary = `${elmSource}/node_modules/.bin/elm`;
}

const options = { 
  cwd: elmSource, 
  pathToElm: elmBinary, 
  optimize: isProduction, 
  verbose: isDevelopment, 
  debug: isDevelopment  
};

const elmWebpackLoader = {
  loader: 'elm-webpack-loader',
  options: options
};

module.exports = {
  test: /\.elm(\.erb)?$/,
  exclude: [/elm-stuff/, /node_modules/],
  use: isProduction ? [elmWebpackLoader] : [{ loader: 'elm-hot-webpack-loader' }, elmWebpackLoader]
};
