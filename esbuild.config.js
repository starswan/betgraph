// esbuild.config.js
const path = require('path')
const ElmPlugin = require('esbuild-plugin-elm')
const esbuild = require('esbuild')
const coffeeScriptPlugin = require('esbuild-coffeescript')

coffee_options = { transpile: { "presets": ["@babel/preset-env"] } }

// the absWorkingDirectory set below allows us to use paths relative to that location
esbuild.build({
    // entryPoints: ['./application.js', './*.coffee'],
    entryPoints: ['application.js', 'active_admin.js', 'bet_markets.coffee', 'betfair_events.coffee', 'market_price_times.coffee', 'matches.coffee'],
    bundle: true,
    outdir: path.join(process.cwd(), "app/assets/builds"),
    absWorkingDir: path.join(process.cwd(), "app/javascript"),
    watch: process.argv.includes("--watch"),
    sourcemap: true,
    plugins: [
        coffeeScriptPlugin(coffee_options),
        ElmPlugin()
    ],
}).catch(e => (console.error(e), process.exit(1)))

//
// require('esbuild').build({
//     entryPoints: ['main.coffee'],
//     bundle: true,
//     outfile: 'out.js',
//     plugins: [coffeeScriptPlugin()],
// });