z = require 'zorium'
Rx = require 'rxjs'
_filter = require 'lodash/filter'
Environment = require 'clay-environment'

Head = require '../../components/head'
BannedUserList = require '../../components/banned_user_list'
AppBar = require '../../components/app_bar'
Icon = require '../../components/icon'
ButtonBack = require '../../components/button_back'
Tabs = require '../../components/tabs'
ProfileDialog = require '../../components/profile_dialog'
ReportedMessages = require '../../components/reported_messages'
config = require '../../config'
colors = require '../../colors'

FormatService = require '../../services/format'

if window?
  require './index.styl'

MIN_MS_BETWEEN_REFRESH = 2000

module.exports = class ModHubPage
  constructor: ({@model, requests, @router, serverData}) ->
    gameKey = requests.map ({route}) ->
      route.params.gameKey or config.DEFAULT_GAME_KEY

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: 'Mod hub'
        description: 'Mod hub'
      }
    })

    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@router, @model}
    selectedIndex = new Rx.BehaviorSubject 0
    @selectedProfileDialogUser = new Rx.BehaviorSubject null

    me = @model.user.getMe()
    # @messagesStreams = new Rx.ReplaySubject 1
    # # https://github.com/ReactiveX/RxJS/issues/1121
    # @messagesStreams.next @model.mod.getAllReportedMessages().share()

    @$refreshIcon = new Icon()
    @$profileDialog = new ProfileDialog {
      @model, @portal, @router, @selectedProfileDialogUser, gameKey
    }

    @$tempBanned = new BannedUserList {
      @model
      @portal
      selectedProfileDialogUser: @selectedProfileDialogUser
      bans: @model.mod.getAllBanned {duration: '24h'}
    }

    @$permanentBanned = new BannedUserList {
      @model
      @portal
      selectedProfileDialogUser: @selectedProfileDialogUser
      bans: @model.mod.getAllBanned {duration: 'permanent'}
    }

    # @$reportedMessages = new ReportedMessages {
    #   @model, @selectedProfileDialogUser, messages: @messagesStreams.switch()
    # }

    @$tabs = new Tabs {@model, selectedIndex}

    @state = z.state
      me: me
      selectedIndex: selectedIndex
      gameKey: gameKey
      isLoading: false
      lastRefreshTime: null
      selectedProfileDialogUser: @selectedProfileDialogUser

  renderHead: => @$head

  render: =>
    {me, selectedIndex, selectedProfileDialogUser, gameKey
      isLoading, lastRefreshTime} = @state.getValue()

    if not me?.flags?.isModerator
      return null

    z '.p-mod-hub',
      z @$appBar,
        color: colors.$primary500Text
        isFlat: true
        $topLeftButton:
          z @$buttonBack,
            color: colors.$primary500
            onclick: =>
              @router.go 'home', {gameKey}
        # $topRightButton:
        #   if isLoading
        #     '...'
        #   else
        #     z @$refreshIcon,
        #       icon: 'refresh'
        #       color: colors.$primary500Text
        #       isAlignedRight: true
        #       onclick: =>
        #         now = Date.now()
        #         if now - lastRefreshTime < MIN_MS_BETWEEN_REFRESH
        #           return
        #
        #         @state.set isLoading: true, lastRefreshTime: now
        #         # messageUpdates = @model.mod.getAllReportedMessages({
        #         #   skipCache: true
        #         # }).share()
        #         # # SUPER HACKY: find a better way to do this (detect when
        #         # # req is done loading, without an extra subscription)
        #         # # if we pass messageUpdates directly, since it's subscribed
        #         # # to for sent, received, done, it gets called 3 times
        #         # # (skipping the cache)
        #         # messageUpdates.take(1).toPromise().then =>
        #         #   @state.set isLoading: false
        #
        #         @messagesStreams.next messageUpdates
        title: 'Mod Hub'

      z @$tabs,
        isBarFixed: false
        hasAppBar: true
        tabs: [
          # {
          #   $menuText: 'reported'
          #   $el:
          #     z @$reportedMessages
          # }
          {
            $menuText: 'Temp banned'
            $el:
              z @$tempBanned
          }
          {
            $menuText: 'Perm banned'
            $el:
              z @$permanentBanned
          }
        ]

      if selectedProfileDialogUser
        z @$profileDialog, {user: selectedProfileDialogUser}
