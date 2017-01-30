z = require 'zorium'
Rx = require 'rx-lite'
FloatingActionButton = require 'zorium-paper/floating_action_button'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
Decks = require '../../components/decks'
DeckGuides = require '../../components/deck_guides'
Tabs = require '../../components/tabs'
Icon = require '../../components/icon'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class DecksPage
  constructor: ({@model, requests, @router, serverData}) ->
    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: 'Battle Decks'
        description: 'Battle Decks'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model}
    @$fab = new FloatingActionButton()
    @$addIcon = new Icon()

    @$deckGuides = new DeckGuides {@model, @router, sort: 'popular'}
    @$recentDecks = new Decks {@model, @router, sort: 'recent', filter: 'mine'}
    @$popularDecks = new Decks {@model, @router, sort: 'popular'}

    selectedIndex = new Rx.BehaviorSubject 0
    @$tabs = new Tabs {@model, selectedIndex}

    @state = z.state
      windowSize: @model.window.getSize()
      selectedIndex: selectedIndex
      me: @model.user.getMe()

  renderHead: => @$head

  render: =>
    {windowSize, selectedIndex, me} = @state.getValue()

    z '.p-decks', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: 'Battle Decks'
        isFlat: true
        $topLeftButton: z @$buttonMenu, {color: colors.$tertiary900}
        $topRightButton: null # FIXME
      }

      z @$tabs,
        isBarFixed: false
        tabs: [
          {
            $menuText: 'Guides'
            $el: @$deckGuides
          }
          {
            $menuText: 'My Decks'
            $el: @$recentDecks
          }
          {
            $menuText: 'Popular'
            $el: @$popularDecks
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
            @model.signInDialog.openIfGuest me
            .then =>
              if selectedIndex is 0
                @router.go '/addGuide'
              else
                @router.go '/addDeck'
