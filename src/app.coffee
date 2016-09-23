z = require 'zorium'
Rx = require 'rx-lite'
HttpHash = require 'http-hash'
_forEach = require 'lodash/collection/forEach'

config = require './config'
gulpPaths = require '../gulp_paths'
HomePage = require './pages/home'
ConversationPage = require './pages/conversation'
ConversationsPage = require './pages/conversations'
ThreadPage = require './pages/thread'
ThreadsPage = require './pages/threads'
NewThread = require './pages/new_thread'
ProfilePage = require './pages/profile'
LearnMorePage = require './pages/learn_more'
FourOhFourPage = require './pages/404'
Drawer = require './components/drawer'

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
    route '/conversation/:userId', ConversationPage
    route '/conversations', ConversationsPage
    route '/thread/:userId/:page', ThreadPage
    route '/threads', ThreadsPage
    route '/newThread', NewThreadPage
    route '/profile', ProfilePage
    route '/learnMore', LearnMorePage
    route '/*', FourOhFourPage

    $backupPage = if serverData?
      routes.get(serverData.req.path).handler()
    else
      null

    @$drawer = new Drawer({model, router})

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

            z @$drawer, {currentPath: request?.req.path}
