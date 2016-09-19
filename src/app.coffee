z = require 'zorium'
Rx = require 'rx-lite'
HttpHash = require 'http-hash'
_forEach = require 'lodash/collection/forEach'

config = require './config'
gulpPaths = require '../gulp_paths'
HomePage = require './pages/home'
FourOhFourPage = require './pages/404'

module.exports = class App
  constructor: ({requests, serverData, model, router}) ->
    routes = new HttpHash()

    requests = requests.map (req) ->
      route = routes.get req.path
      {req, route, $page: route.handler()}

    route = (paths, Page) ->
      if typeof paths is 'string'
        paths = [paths]

      $page = new Page({
        model
        router
        serverData
        requests: requests.filter ({$page}) ->
          $page instanceof Page
      })
      _forEach paths, (path) ->
        routes.set path, -> $page

    route '/', HomePage
    route '/*', FourOhFourPage

    $backupPage = if serverData?
      routes.get(serverData.req.path).handler()
    else
      null

    @state = z.state {
      rand: null
      $backupPage
      request: requests.doOnNext ({$page, req}) ->
        if $page instanceof FourOhFourPage
          res?.status? 404
    }

  onResize: =>
    # re-render
    @state.set rand: Math.random()

  render: =>
    {request, $backupPage, $modal} = @state.getValue()

    z 'html',
      request?.$page.renderHead() or $backupPage?.renderHead()
      z 'body',
        z '#zorium-root',
          z '.z-root',
            request?.$page or $backupPage
