z = require 'zorium'
Rx = require 'rx-lite'
HttpHash = require 'http-hash'
_forEach = require 'lodash/forEach'

HomePage = require './pages/home'
SignInPage = require './pages/sign_in'
JoinPage = require './pages/join'
FriendsPage = require './pages/friends'
ConversationPage = require './pages/conversation'
ConversationsPage = require './pages/conversations'
NewConversationPage = require './pages/new_conversation'
CommunityPage = require './pages/community'
GroupPage = require './pages/group'
EditGroupPage = require './pages/edit_group'
NewGroupPage = require './pages/new_group'
ThreadPage = require './pages/thread'
ThreadReplyPage = require './pages/thread_reply'
NewThreadPage = require './pages/new_thread'
NewDeckPage = require './pages/new_deck'
DeckPage = require './pages/deck'
DecksPage = require './pages/decks'
CardPage = require './pages/card'
CardsPage = require './pages/cards'
ProfilePage = require './pages/profile'
TosPage = require './pages/tos'
PoliciesPage = require './pages/policies'
SetAddressPage = require './pages/set_address'
GetAppPage = require './pages/get_app'
PrivacyPage = require './pages/privacy'
EditProfilePage = require './pages/edit_profile'
FourOhFourPage = require './pages/404'
Drawer = require './components/drawer'

# TODO: is there a way we can not construct every single Page class for every
# page load?

module.exports = class App
  constructor: ({requests, serverData, model, router}) ->
    routes = new HttpHash()

    requests = requests.map (req) ->
      route = routes.get req.path
      {req, route, $page: route.handler?()}

    $cachedPages = []
    route = (paths, Page) ->
      if typeof paths is 'string'
        paths = [paths]

      _forEach paths, (path) ->
        routes.set path, ->
          unless $cachedPages[path]
            $cachedPages[path] = new Page({
              model
              router
              serverData
              requests: requests.filter ({$page}) ->
                $page instanceof Page
            })
          return $cachedPages[path]

    route '/', HomePage
    # route '/', CommunityPage
    route ['/friends/:action', '/friends'], FriendsPage
    route '/conversation/:conversationId', ConversationPage
    route '/conversations', ConversationsPage
    route '/newConversation', NewConversationPage
    route '/thread/:id/reply', ThreadReplyPage
    route '/thread/:id/:page', ThreadPage
    route '/community', CommunityPage
    route '/group/:id', GroupPage
    route '/group/:id/edit', EditGroupPage
    route '/newGroup', NewGroupPage
    route '/newThread', NewThreadPage
    route '/newDeck', NewDeckPage
    route '/decks', DecksPage
    route '/cards', CardsPage
    route '/decks/:id', DeckPage
    route '/cards/:id', CardPage
    route '/policies', PoliciesPage
    route '/tos', TosPage
    route '/privacy', PrivacyPage
    route '/signIn', SignInPage
    route '/join', JoinPage
    route '/setAddress', SetAddressPage
    route '/getApp', GetAppPage
    route '/profile', ProfilePage
    route '/editProfile', EditProfilePage
    route '/*', FourOhFourPage

    $backupPage = if serverData?
      routes.get(serverData.req.path).handler()
    else
      null

    @$drawer = new Drawer({model, router})

    me = model.user.getMe()

    @state = z.state {
      rand: null
      $backupPage
      me: me
      request: requests.doOnNext ({$page, req}) ->
        if $page instanceof FourOhFourPage
          res?.status? 404
    }

  onResize: =>
    # re-render
    @state.set rand: Math.random()

  render: =>
    {request, $backupPage, $modal, me} = @state.getValue()

    userAgent = request?.req?.headers?['user-agent'] or
      navigator?.userAgent or ''
    isIos = /iPad|iPhone|iPod/.test userAgent
    isPageAvailable = (me?.isMember or request?.$page?.isPublic)

    z 'html',
      request?.$page.renderHead() or $backupPage?.renderHead()
      z 'body',
        z '#zorium-root', {className: z.classKebab {isIos}},
          z '.z-root',
            unless request?.$page?.hideDrawer
              z @$drawer, {currentPath: request?.req.path}
            z '.page',
              # show page before me has loaded
              if (not me or isPageAvailable) and request?.$page
                request.$page
              else
                $backupPage
