z = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
Threads = require '../../components/threads'
FilterThreadsDialog = require '../../components/filter_threads_dialog'
Icon = require '../../components/icon'
Fab = require '../../components/fab'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class GroupForumPage
  isGroup: true
  @hasBottomBar: true
  constructor: ({@model, requests, @router, serverData, group, @$bottomBar}) ->
    @isFilterThreadsDialogVisible = new RxBehaviorSubject false
    filter = new RxBehaviorSubject {
      sort: 'popular'
      filter: 'all'
    }

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

    @$threads = new Threads {@model, @router, filter, group}

    @state = z.state
      windowSize: @model.window.getSize()
      isFilterThreadsDialogVisible: @isFilterThreadsDialogVisible
      group: group

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
    {windowSize, isFilterThreadsDialogVisible, group} = @state.getValue()

    z '.p-group-forum', {
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
            hasRipple: true
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
            @router.go 'newThread', {group}
