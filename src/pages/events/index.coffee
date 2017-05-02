z = require 'zorium'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
Events = require '../../components/events'
Tabs = require '../../components/tabs'
Icon = require '../../components/icon'
Fab = require '../../components/fab'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class EventsPage
  constructor: ({@model, requests, @router, serverData}) ->
    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'eventsPage.title'
        description: @model.l.get 'eventsPage.title'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model}
    @$fab = new Fab()
    @$addIcon = new Icon()

    @$allEvents = new Events {@model, @router}
    @$myEvents = new Events {@model, @router, filter: 'mine'}

    @$tabs = new Tabs {@model}

    @state = z.state
      me: @model.user.getMe()
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize, me} = @state.getValue()

    z '.p-decks', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'eventsPage.title'
        isFlat: true
        $topLeftButton: z @$buttonMenu, {color: colors.$tertiary900}
      }

      z @$tabs,
        isBarFixed: false
        tabs: [
          {
            $menuText: @model.l.get 'eventsPage.menuTextAvailable'
            $el: @$allEvents
          }
          {
            $menuText: @model.l.get 'eventsPage.menuTextMine'
            $el: @$myEvents
          }
        ]

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
            @model.signInDialog.openIfGuest(me)
            .then =>
              @router.go '/addEvent'
