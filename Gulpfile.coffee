fs = require 'fs'
del = require 'del'
_defaults = require 'lodash/defaults'
_defaultsDeep = require 'lodash/defaultsDeep'
_mapValues = require 'lodash/mapValues'
log = require 'loga'
gulp = require 'gulp'
gutil = require 'gulp-util'
webpack = require 'webpack'
mocha = require 'gulp-mocha'
manifest = require 'gulp-manifest'
KarmaServer = require('karma').Server
spawn = require('child_process').spawn
coffeelint = require 'gulp-coffeelint'
webpackStream = require 'webpack-stream'
# istanbul = require 'gulp-coffee-istanbul'
WebpackDevServer = require 'webpack-dev-server'
ExtractTextPlugin = require 'extract-text-webpack-plugin'
# UglifyJSPlugin = require 'uglifyjs-webpack-plugin'
# Visualizer = require('webpack-visualizer-plugin')

config = require './src/config'
paths = require './gulp_paths'

FUNCTIONAL_TEST_TIMEOUT_MS = 10 * 1000 # 10sec

karmaConfig =
  singleRun: true
  frameworks: ['mocha']
  files: [paths.build + '/bundle.js']
  preprocessors:
    '**/*.js': ['sourcemap']
  browsers: ['Chrome', 'Firefox']

cssLoader = 'css!autoprefixer!stylus?paths[]=node_modules'

webpackBase =
  module:
    exprContextRegExp: /$^/
    exprContextCritical: false
  resolve:
    extensions: ['.coffee', '.js', '.json', '']
  output:
    filename: 'bundle.js'
    publicPath: '/'

gulp.task 'dev', ['dev:webpack-server', 'watch:dev:server']
gulp.task 'test', ['lint', 'test:coverage', 'test:browser']
# TODO: 'dist:manifest' - appcache
gulp.task 'dist', ['dist:scripts', 'dist:static']

gulp.task 'watch', ->
  gulp.watch paths.coffee, ['test:unit']
gulp.task 'watch:phantom', ->
  gulp.watch paths.coffee, ['test:browser:phantom']
gulp.task 'watch:server', ->
  gulp.watch paths.coffee, ['test:server']
gulp.task 'watch:functional', ->
  gulp.watch paths.coffee, ['test:functional']
gulp.task 'watch:dev:server', ['dev:server'], ->
  gulp.watch paths.coffee, ['dev:server']

gulp.task 'lint', ->
  gulp.src paths.coffee
    .pipe coffeelint()
    .pipe coffeelint.reporter()

# gulp.task 'test:coverage', ->
#   gulp.src paths.cover
#     .pipe istanbul includeUntested: false
#     .pipe istanbul.hookRequire()
#     .on 'finish', ->
#       gulp.src paths.unitTests.concat [paths.serverTests]
#         .pipe mocha()
#         .pipe istanbul.writeReports({
#           reporters: ['html', 'text', 'text-summary']
#         })

gulp.task 'test:unit', ->
  gulp.src paths.unitTests
    .pipe mocha()

gulp.task 'test:browser:phantom', ['build:scripts:test'], (cb) ->
  new KarmaServer _defaults({
    browsers: ['PhantomJS']
  }, karmaConfig), cb
  .start()

gulp.task 'test:server', ->
  gulp.src paths.serverTests
    .pipe mocha()

gulp.task 'test:browser', ['build:scripts:test'], (cb) ->
  new KarmaServer karmaConfig, cb
  .start()

gulp.task 'test:functional', ->
  gulp.src paths.functionalTests
    .pipe mocha(timeout: FUNCTIONAL_TEST_TIMEOUT_MS)

gulp.task 'dev:server', ['build:static:dev'], do ->
  devServer = null
  process.on 'exit', -> devServer?.kill()
  ->
    devServer?.kill()
    devServer = spawn 'coffee', ['bin/dev_server.coffee'], {stdio: 'inherit'}
    devServer.on 'close', (code) ->
      if code is 8
        gulp.log 'Error detected, waiting for changes'

gulp.task 'dev:webpack-server', ->
  entries = [
    "webpack-dev-server/client?#{config.WEBPACK_DEV_URL}"
    'webpack/hot/dev-server'
    paths.root
  ]

  compiler = webpack _defaultsDeep {
    devtool: 'inline-source-map'
    entry: entries
    output:
      path: __dirname
      publicPath: "#{config.WEBPACK_DEV_URL}/"
    module:
      loaders: [
        {test: /\.coffee$/, loader: 'coffee'}
        {test: /\.json$/, loader: 'json'}
        {test: /\.styl$/, loader: 'style!' + cssLoader}
      ]
    plugins: [
      new webpack.HotModuleReplacementPlugin()
      new webpack.DefinePlugin
        'process.env': _mapValues process.env, (val) -> JSON.stringify val
    ]
  }, webpackBase

  webpackOptions =
    publicPath: "#{config.WEBPACK_DEV_URL}/"
    hot: true
    headers: 'Access-Control-Allow-Origin': '*'
    noInfo: true
    disableHostCheck: true

  if config.DEV_USE_HTTPS
    console.log 'using https'
    webpackOptions.https = true
    webpackOptions.key = fs.readFileSync './bin/starfire-dev.key'
    webpackOptions.cert = fs.readFileSync './bin/starfire-dev.crt'

  new WebpackDevServer compiler, webpackOptions
  .listen config.WEBPACK_DEV_PORT, (err) ->
    if err
      log.error err
    else
      log.info
        event: 'webpack_server_start'
        message: "Webpack listening on port #{config.WEBPACK_DEV_PORT}"

gulp.task 'build:static:dev', ->
  gulp.src paths.static
    .pipe gulp.dest paths.build

gulp.task 'build:scripts:test', ->
  gulp.src paths.unitTests
  .pipe webpackStream _defaultsDeep {
    devtool: 'inline-source-map'
    module:
      loaders: [
        {test: /\.coffee$/, loader: 'coffee'}
        {test: /\.json$/, loader: 'json'}
        {test: /\.styl$/, loader: 'style!' + cssLoader}
      ]
    plugins: [
      new webpack.DefinePlugin
        'process.env': _mapValues process.env, (val) -> JSON.stringify val
    ]
  }, webpackBase
  .pipe gulp.dest paths.build

gulp.task 'dist:clean', (cb) ->
  del paths.dist, cb

gulp.task 'dist:static', ['dist:clean'], ->
  gulp.src paths.static
    .pipe gulp.dest paths.dist

gulp.task 'dist:sw', ->
  gulp.src paths.sw
  .pipe webpackStream
    module:
      loaders: [
        {test: /\.coffee$/, loader: 'coffee'}
        {test: /\.json$/, loader: 'json'}
      ]
    output:
      filename: 'service_worker.js'
    plugins: [
      # new webpack.IgnorePlugin(/^\.\/locale$/, [/moment$/])
      # new webpack.optimize.UglifyJsPlugin
      #   mangle:
      #     except: ['process']
    ]
    resolve:
      extensions: ['.coffee', '.js', '.json', '']
  .pipe gulp.dest paths.dist

gulp.task 'dist:scripts', ['dist:clean', 'dist:sw'], ->
  scriptsConfig = _defaultsDeep {
    # devtool: 'source-map'
    plugins: [
      # new Visualizer()
      # new webpack.IgnorePlugin(/^\.\/locale$/, [/moment$/])
      new webpack.ContextReplacementPlugin(
        /moment[\/\\]locale$/, /en|es|it|fr|zh|ja|ko|de|pt|pl/
      )
      # new UglifyJSPlugin
      #   uglifyOptions:
      #     mangle:
      #       reserved: ['process']
      new webpack.optimize.UglifyJsPlugin
        mangle:
          except: ['process']
      new ExtractTextPlugin 'bundle.css'
    ]
    output:
      # TODO: '[hash].bundle.js' if we have caching issues, or use appcache
      filename: 'bundle.js'
    module:
      loaders: [
        {test: /\.coffee$/, loader: 'coffee'}
        {test: /\.json$/, loader: 'json'}
        {
          test: /\.styl$/
          loader: ExtractTextPlugin.extract 'style', cssLoader
        }
      ]
  }, webpackBase

  gulp.src paths.root
  .pipe webpackStream scriptsConfig, null, (err, stats) ->
    if err
      gutil.log err
      return
    statsJson = JSON.stringify {hash: stats.toJson().hash}
    fs.writeFileSync "#{__dirname}/#{paths.dist}/stats.json", statsJson
  .pipe gulp.dest paths.dist

gulp.task 'dist:manifest', ['dist:static', 'dist:scripts'], ->
  gulp.src paths.manifest
    .pipe manifest {
      hash: true
      timestamp: false
      preferOnline: true
      fallback: ['/ /offline.html']
    }
    .pipe gulp.dest paths.dist
