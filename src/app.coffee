z = require 'zorium'
Rx = require 'rx-lite'
HttpHash = require 'http-hash'
_forEach = require 'lodash/forEach'
Environment = require 'clay-environment'

Drawer = require './components/drawer'
SignInDialog = require './components/sign_in_dialog'
InstallOverlay = require './components/install_overlay'
GetAppDialog = require './components/get_app_dialog'
AddToHomeScreenSheet = require './components/add_to_home_sheet'
PushNotificationsSheet = require './components/push_notifications_sheet'
ConversationImageView = require './components/conversation_image_view'
OfflineOverlay = require './components/offline_overlay'
config = require './config'

Pages =
  HomePage: require './pages/home'
  FriendsPage: require './pages/friends'
  VideosPage: require './pages/videos'
  ClanPage: require './pages/clan'
  ConversationPage: require './pages/conversation'
  ConversationsPage: require './pages/conversations'
  NewConversationPage: require './pages/new_conversation'
  AddEventPage: require './pages/add_event'
  EditEventPage: require './pages/edit_event'
  EventPage: require './pages/event'
  EventsPage: require './pages/events'
  FacebookLoginPage: require './pages/facebook_login'
  ForumSignaturePage: require './pages/forum_signature'
  GroupPage: require './pages/group'
  GroupChatPage: require './pages/group_chat'
  GroupMembersPage: require './pages/group_members'
  GroupSettingsPage: require './pages/group_settings'
  GroupInvitesPage: require './pages/group_invites'
  GroupInvitePage: require './pages/group_invite'
  GroupAddRecordsPage: require './pages/group_add_records'
  GroupManageRecordsPage: require './pages/group_manage_records'
  GroupManageChannelsPage: require './pages/group_manage_channels'
  GroupAddChannelPage: require './pages/group_add_channel'
  GroupEditChannelPage: require './pages/group_edit_channel'
  GroupManageMemberPage: require './pages/group_manage_member'
  AddGuidePage: require './pages/add_guide'
  EditGuidePage: require './pages/edit_guide'
  ThreadPage: require './pages/thread'
  ThreadReplyPage: require './pages/thread_reply'
  NewThreadPage: require './pages/new_thread'
  AddDeckPage: require './pages/add_deck'
  DeckPage: require './pages/deck'
  DecksPage: require './pages/decks'
  DecksNewPage: require './pages/decks_new'
  CardPage: require './pages/card'
  CardsPage: require './pages/cards'
  ModHubPage: require './pages/mod_hub'
  PlayersPage: require './pages/players'
  PlayersSearchPage: require './pages/players_search'
  ProfilePage: require './pages/profile'
  ProfileChestsPage: require './pages/profile_chests'
  SocialPage: require './pages/social'
  RecruitingPage: require './pages/recruiting'
  StarPage: require './pages/star'
  StarsPage: require './pages/stars'
  TosPage: require './pages/tos'
  PoliciesPage: require './pages/policies'
  PrivacyPage: require './pages/privacy'
  EditProfilePage: require './pages/edit_profile'
  FourOhFourPage: require './pages/404'

TIME_UNTIL_ADD_TO_HOME_PROMPT_MS = 90000 # 1.5 min

module.exports = class App
  constructor: ({requests, @serverData, @model, @router, isOffline}) ->
    @$cachedPages = []
    routes = @model.window.getBreakpoint().map @getRoutes

    requestsAndRoutes = Rx.Observable.combineLatest(
      requests, routes, (vals...) -> vals
    )

    @requests = requestsAndRoutes.map ([req, routes]) ->
      route = routes.get req.path
      $page = route.handler?()
      {req, route, $page: $page}

    # used if state / requests fails to work
    $backupPage = if @serverData?
      @getRoutes().get(@serverData.req.path).handler?()
    else
      null

    addToHomeSheetIsVisible = new Rx.BehaviorSubject false

    @$offlineOverlay = new OfflineOverlay {@model, isOffline}
    @$drawer = new Drawer {@model, @router}
    @$signInDialog = new SignInDialog {@model, @router}
    @$getAppDialog = new GetAppDialog {@model, @router}
    @$installOverlay = new InstallOverlay {@model, @router}
    @$conversationImageView = new ConversationImageView {@model, @router}
    @$addToHomeSheet = new AddToHomeScreenSheet {
      @model
      @router
      isVisible: addToHomeSheetIsVisible
    }
    @$pushNotificationsSheet = new PushNotificationsSheet {@model, @router}

    me = @model.user.getMe()

    if localStorage? and not localStorage['lastAddToHomePromptTime']
      setTimeout ->
        isNative = Environment.isGameApp(config.GAME_KEY)
        if not isNative and not localStorage['lastAddToHomePromptTime']
          addToHomeSheetIsVisible.onNext true
          localStorage['lastAddToHomePromptTime'] = Date.now()
      , TIME_UNTIL_ADD_TO_HOME_PROMPT_MS

    @state = z.state {
      $backupPage: $backupPage
      me: me
      isOffline: isOffline
      addToHomeSheetIsVisible: addToHomeSheetIsVisible
      signInDialogIsOpen: @model.signInDialog.isOpen()
      getAppDialogIsOpen: @model.getAppDialog.isOpen()
      pushNotificationSheetIsOpen: @model.pushNotificationSheet.isOpen()
      installOverlayIsOpen: @model.installOverlay.isOpen()
      imageViewOverlayImageData: @model.imageViewOverlay.getImageData()
      hideDrawer: @requests.flatMapLatest (request) ->
        hideDrawer = request.$page?.hideDrawer
        if hideDrawer?.map
        then hideDrawer
        else Rx.Observable.just (hideDrawer or false)
      request: @requests.doOnNext ({$page, req}) ->
        if $page instanceof Pages['FourOhFourPage']
          res?.status? 404
    }

  getRoutes: (breakpoint) =>
    routes = new HttpHash()

    route = (paths, pageKey) =>
      Page = Pages[pageKey]
      if typeof paths is 'string'
        paths = [paths]

      _forEach paths, (path) =>
        routes.set path, =>
          unless @$cachedPages[pageKey]
            @$cachedPages[pageKey] = new Page({
              @model
              @router
              @serverData
              requests: @requests.filter ({$page}) ->
                $page instanceof Page
            })
          return @$cachedPages[pageKey]


    # route '/', 'HomePage'
    route ['/friends/:action', '/friends'], 'FriendsPage'
    route '/videos', 'VideosPage'
    route '/clan', 'ClanPage'
    route '/conversation/:conversationId', 'ConversationPage'
    route '/conversations', 'ConversationsPage'
    route '/newConversation', 'NewConversationPage'
    route '/addEvent', 'AddEventPage'
    route '/events', 'EventsPage'
    route '/event/:id', 'EventPage'
    route '/event/:id/edit', 'EditEventPage'
    route '/thread/:id', 'ThreadPage'
    route '/thread/:id/reply', 'ThreadReplyPage'

    route '/decksNew', 'DecksNewPage'

    if breakpoint is 'desktop'
      route ['/decks', '/deckGuide/:id'], 'DecksPage'
    else
      route ['/decks'], 'DecksPage'

    route '/forumSignature', 'ForumSignaturePage'

    route '/group/:id', 'GroupPage'
    route '/group/:id/chat', 'GroupChatPage'
    route '/group/:id/members', 'GroupMembersPage'
    route '/group/:id/chat/:conversationId', 'GroupChatPage'
    route '/group/:id/invite', 'GroupInvitePage'
    route '/group/:id/manage/:userId', 'GroupManageMemberPage'
    route '/group/:id/manageChannels', 'GroupManageChannelsPage'
    route '/group/:id/newChannel', 'GroupAddChannelPage'
    route(
      '/group/:id/editChannel/:conversationId', 'GroupEditChannelPage'
    )
    route '/group/:id/settings', 'GroupSettingsPage'
    route '/group/:id/addRecords', 'GroupAddRecordsPage'
    route '/group/:id/manageRecords', 'GroupManageRecordsPage'
    route '/groupInvites', 'GroupInvitesPage'
    route '/addGuide', 'AddGuidePage'
    route '/editGuide/:id', 'EditGuidePage'
    route ['/newThread', '/newThread/:category'], 'NewThreadPage'
    route '/addDeck', 'AddDeckPage'
    route '/cards', 'CardsPage'
    route '/deck/:id', 'DeckPage'
    route ['/card/:id', '/clashRoyale/card/:key'], 'CardPage'
    route '/facebookLogin/:type', 'FacebookLoginPage'
    route '/modHub', 'ModHubPage'
    route '/players', 'PlayersPage'
    route '/players/search', 'PlayersSearchPage'
    route '/policies', 'PoliciesPage'
    route '/social', 'SocialPage'
    route '/recruiting', 'RecruitingPage'
    route '/stars', 'StarsPage'
    route '/star/:username', 'StarPage'
    route '/tos', 'TosPage'
    route '/privacy', 'PrivacyPage'
    route [
      '/', '/profile', '/user/id/:id', '/user/:username'
    ], 'ProfilePage'
    route [
      '/user/id/:id/chests'
      '/user/:username/chests'
    ], 'ProfileChestsPage'
    route '/editProfile', 'EditProfilePage'
    route '/*', 'FourOhFourPage'
    routes

  render: =>
    {request, $backupPage, $modal, me, imageViewOverlayImageData, hideDrawer
      installOverlayIsOpen, signInDialogIsOpen, pushNotificationSheetIsOpen
      getAppDialogIsOpen, addToHomeSheetIsVisible,
      isOffline} = @state.getValue()

    userAgent = request?.req?.headers?['user-agent'] or
      navigator?.userAgent or ''
    isIos = /iPad|iPhone|iPod/.test userAgent
    isNative = Environment.isGameApp(config.GAME_KEY)
    isPageAvailable = (me?.isMember or not request?.$page?.isPrivate)
    defaultInstallMessage = 'Add Starfi.re to your homescreen to quickly
                            access all features anytime'

    z 'html',
      request?.$page?.renderHead() or $backupPage?.renderHead()
      z 'body',
        z '#zorium-root', {
          className: z.classKebab {isIos}
        },
          z '.z-root',
            unless hideDrawer
              z @$drawer, {currentPath: request?.req.path}
            z '.page',
              # show page before me has loaded
              if (not me or isPageAvailable) and request?.$page
                request.$page
              else
                $backupPage

            if signInDialogIsOpen
              z @$signInDialog
            if getAppDialogIsOpen
              z @$getAppDialog
            if installOverlayIsOpen
              z @$installOverlay
            if imageViewOverlayImageData
              z @$conversationImageView
            if addToHomeSheetIsVisible
              z @$addToHomeSheet, {
                message: request?.$page?.installMessage or defaultInstallMessage
              }
            if pushNotificationSheetIsOpen
              z @$pushNotificationsSheet
            if isOffline
              z @$offlineOverlay
