z = require 'zorium'

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

    @$threads = new Threads {@model, @router, category: 'clan', sort: 'new'}

    @state = z.state
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

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
            @router.go '/new-thread/clan'
