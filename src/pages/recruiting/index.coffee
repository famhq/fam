z = require 'zorium'
Rx = require 'rxjs'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
Threads = require '../../components/threads'
Icon = require '../../components/icon'
Fab = require '../../components/fab'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class RecruitingPage
  constructor: ({@model, requests, @router, serverData}) ->
    gameKey = requests.map ({route}) ->
      route.params.gameKey or config.DEFAULT_GAME_KEY

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'general.recruiting'
        description: @model.l.get 'general.recruiting'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model}
    @$fab = new Fab()
    @$addIcon = new Icon()

    filter = new Rx.BehaviorSubject {sort: 'new', filter: 'clan'}
    @$threads = new Threads {@model, @router, filter, gameKey}

    @state = z.state
      windowSize: @model.window.getSize()
      gameKey: gameKey

  renderHead: => @$head

  render: =>
    {windowSize, gameKey} = @state.getValue()

    z '.p-recruiting', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'general.recruiting'
        isFlat: true
        $topLeftButton: z @$buttonMenu, {color: colors.$primary500}
      }
      @$threads

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
            @router.go 'newThreadWithCategory', {gameKey, category: 'clan'}
