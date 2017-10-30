z = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
Threads = require '../../components/threads'
FilterThreadsDialog = require '../../components/filter_threads_dialog'
BottomBar = require '../../components/bottom_bar'
Icon = require '../../components/icon'
Fab = require '../../components/fab'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class ForumPage
  constructor: ({@model, requests, @router, serverData}) ->
    @isFilterThreadsDialogVisible = new RxBehaviorSubject false
    filter = new RxBehaviorSubject {
      sort: 'popular'
      filter: 'all'
    }
    gameKey = requests.map ({route}) ->
      route.params.gameKey or config.DEFAULT_GAME_KEY

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'general.forum'
        description: @model.l.get 'general.forum'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model}
    @$fab = new Fab()
    @$addIcon = new Icon()
    @$filterIcon = new Icon()
    @$filterThreadsDialog = new FilterThreadsDialog {
      @model, filter, isVisible: @isFilterThreadsDialogVisible
    }
    @$bottomBar = new BottomBar {@model, @router, requests}

    @$threads = new Threads {@model, @router, filter, gameKey}

    @state = z.state
      windowSize: @model.window.getSize()
      gameKey: gameKey
      isFilterThreadsDialogVisible: @isFilterThreadsDialogVisible

  renderHead: => @$head

  afterMount: =>
    @model.user.getMe().switchMap ({id}) =>
      @model.player.getByUserIdAndGameId id, config.CLASH_ROYALE_ID
      .map (mePlayer) =>
        if mePlayer?.isVerified
          @model.player.setAutoRefreshByPlayerIdAndGameId(
            mePlayer.id, config.CLASH_ROYALE_ID
          )
    .take(1)
    .subscribe()

  render: =>
    {windowSize, isFilterThreadsDialogVisible, gameKey} = @state.getValue()

    z '.p-forum', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'general.forum'
        isFlat: true
        $topLeftButton: z @$buttonMenu, {color: colors.$primary500}
        $topRightButton:
          z @$filterIcon,
            color: colors.$primary500
            icon: 'filter'
            onclick: =>
              @isFilterThreadsDialogVisible.next true
      }
      @$threads
      @$bottomBar

      if isFilterThreadsDialogVisible
        z @$filterThreadsDialog

      z '.fab',
        z @$fab,
          colors:
            c500: colors.$primary500
          $icon: z @$addIcon, {
            icon: 'add'
            isTouchTarget: false
            color: colors.$white
          }
          onclick: =>
            @router.go 'newThread', {gameKey}
