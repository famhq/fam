fs = require 'fs'
del = require 'del'
_defaults = require 'lodash/defaults'
_defaultsDeep = require 'lodash/defaultsDeep'
_map = require 'lodash/map'
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
gulpSequence = require 'gulp-sequence'
# istanbul = require 'gulp-coffee-istanbul'
WebpackDevServer = require 'webpack-dev-server'
ExtractTextPlugin = require 'extract-text-webpack-plugin'
# UglifyJSPlugin = require 'uglifyjs-webpack-plugin'
Visualizer = require('webpack-visualizer-plugin')
BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin
s3Upload = require 'gulp-s3-upload'
argv = require('yargs').argv

config = require './src/config'
Language = require './src/lang'
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

s3 = s3Upload {
  accessKeyId: process.env.RADIOACTIVE_AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.RADIOACTIVE_AWS_SECRET_ACCESS_KEY
}

gulp.task 'dev', ['dev:webpack-server', 'watch:dev:server']
gulp.task 'test', ['lint', 'test:coverage', 'test:browser']
# TODO: 'dist:manifest' - appcache
gulp.task 'dist', gulpSequence(
  'dist:clean'
  ['dist:scripts', 'dist:static']
  'dist:concat'
  'dist:s3'
)

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
      # new webpack.IgnorePlugin /\.json$/, /lang/
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
    webpackOptions.key = fs.readFileSync './bin/fam-dev.key'
    webpackOptions.cert = fs.readFileSync './bin/fam-dev.crt'

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
      # new webpack.IgnorePlugin /^\/lang\/*$/
      # new webpack.optimize.UglifyJsPlugin
      #   mangle:
      #     except: ['process']
    ]
    resolve:
      extensions: ['.coffee', '.js', '.json', '']
  .pipe gulp.dest paths.dist

gulp.task 'dist:scripts', ['dist:clean', 'dist:sw'], ->
  _map config.LANGUAGES, (language) ->
    fs.writeFileSync(
      "#{__dirname}/#{paths.dist}/lang_#{language}.json"
      Language.getJsonString language
    )

  scriptsConfig = _defaultsDeep {
    # devtool: 'source-map'
    plugins: [
      new webpack.IgnorePlugin /\.json$/, /lang/
      # new webpack.IgnorePlugin /.*$/, /date-fns\/locale/
      # new UglifyJSPlugin
      #   uglifyOptions:
      #     mangle:
      #       reserved: ['process']
      new webpack.optimize.UglifyJsPlugin
        mangle:
          except: ['process']
      new ExtractTextPlugin 'bundle.css'
      new Visualizer()
      new BundleAnalyzerPlugin()
      # new webpack.IgnorePlugin(/^\.\/locale$/, [/moment$/])
      # new webpack.ContextReplacementPlugin(
      #   /moment[\/\\]locale$/, /en|es|it|fr|zh|ja|ko|de|pt|pl/
      # )
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
    statsJson = JSON.stringify {hash: stats.toJson().hash, time: Date.now()}
    fs.writeFileSync "#{__dirname}/#{paths.dist}/stats.json", statsJson
  .pipe gulp.dest paths.dist

gulp.task 'dist:concat', ->
  bundle = fs.readFileSync "#{__dirname}/#{paths.dist}/bundle.js", 'utf-8'
  matches = bundle.match(/process\.env\.[a-zA-Z0-9_]+/g)
  _map matches, (match) ->
    key = match.replace('process.env.', '')
    bundle = bundle.replace match, "'#{process.env[key]}'"
  stats = JSON.parse fs.readFileSync "#{__dirname}/#{paths.dist}/stats.json"
  _map config.LANGUAGES, (language) ->
    lang = fs.readFileSync(
      "#{__dirname}/#{paths.dist}/lang_#{language}.json", 'utf-8'
    )
    fs.writeFileSync(
      "#{__dirname}/#{paths.dist}/bundle_#{stats.hash}_#{language}.js"
      lang + bundle
    , 'utf-8')

gulp.task 'dist:s3', ->
  gulp.src("#{__dirname}/#{paths.dist}/bundle*")
  .pipe s3 {
    Bucket: 'cdn.wtf'
    ACL: 'public-read'
    keyTransform: (relativeFilename) ->
      "d/scripts/fam/#{relativeFilename}"
  }

gulp.task 'dist:manifest', ['dist:static', 'dist:scripts'], ->
  gulp.src paths.manifest
    .pipe manifest {
      hash: true
      timestamp: false
      preferOnline: true
      fallback: ['/ /offline.html']
    }
    .pipe gulp.dest paths.dist
