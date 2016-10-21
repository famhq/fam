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
ThreadReplyPage = require './pages/thread_reply'
NewThreadPage = require './pages/new_thread'
NewDeckPage = require './pages/new_deck'
DeckPage = require './pages/deck'
DecksPage = require './pages/decks'
CardPage = require './pages/card'
CardsPage = require './pages/cards'
ReferPage = require './pages/refer'
PayPage = require './pages/pay'
AcceptInvitePage = require './pages/accept_invite'
ProfilePage = require './pages/profile'
EditProfilePage = require './pages/edit_profile'
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
    # route '/', ThreadsPage
    route '/conversation/:userId', ConversationPage
    route '/conversations', ConversationsPage
    route '/thread/:id/reply', ThreadReplyPage
    route '/thread/:id/:page', ThreadPage
    route '/threads', ThreadsPage
    route '/newThread', NewThreadPage
    route '/newDeck', NewDeckPage
    route '/decks', DecksPage
    route '/cards', CardsPage
    route '/decks/:id', DeckPage
    route '/cards/:id', CardPage
    route '/refer', ReferPage
    route '/pay', PayPage
    route '/acceptInvite', AcceptInvitePage
    route '/profile', ProfilePage
    route '/editProfile', EditProfilePage
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

    userAgent = request?.req?.headers?['user-agent'] or
      navigator?.userAgent or ''
    isIos = /iPad|iPhone|iPod/.test userAgent

    z 'html',
      request?.$page.renderHead() or $backupPage?.renderHead()
      z 'body',
        z '#zorium-root', {className: z.classKebab {isIos}},
          z '.z-root',
            z @$drawer, {currentPath: request?.req.path}
            z '.page',
              request?.$page or $backupPage
