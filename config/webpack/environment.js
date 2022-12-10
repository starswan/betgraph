const { environment } = require('@rails/webpacker');
const jquery = require('./plugins/jquery')

const webpack = require('webpack')
environment.plugins.prepend('Provide',
    new webpack.ProvidePlugin({
        $: 'jquery/src/jquery',
        jQuery: 'jquery/src/jquery'
    })
)

const coffee =  require('./loaders/coffee')
const elm =  require('./loaders/elm');

environment.loaders.prepend('elm', elm);
environment.loaders.prepend('coffee', coffee)
environment.plugins.prepend('jquery', jquery)
module.exports = environment;
