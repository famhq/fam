z = require 'zorium'
Rx = require 'rx-lite'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
DeckList = require '../../components/deck_list'
DeckGuides = require '../../components/deck_guides'
Thread = require '../../components/thread'
Tabs = require '../../components/tabs'
Icon = require '../../components/icon'
Fab = require '../../components/fab'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class Decks
  constructor: ({@model, @router, thread}) ->
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model}
    @$fab = new Fab()
    @$addIcon = new Icon()

    @$deckGuides = new DeckGuides {@model, @router, sort: 'popular'}
    @$recentDecks = new DeckList {
      @model, @router, sort: 'recent', filter: 'mine'
    }
    @$popularDecks = new DeckList {@model, @router, sort: 'popular'}

    selectedIndex = new Rx.BehaviorSubject 0
    @$tabs = new Tabs {@model, selectedIndex}

    @$cachedThread = null

    @state = z.state
      selectedIndex: selectedIndex
      me: @model.user.getMe()
      $sideEl: thread?.map (threadVal) =>
        if threadVal
          unless @$cachedThread
            @$cachedThread = new Thread {
              @model, @router, thread, isInline: true
            }
          @$cachedThread
        else
          null

  render: =>
    {selectedIndex, me, $sideEl} = @state.getValue()

    z '.z-decks',
      z '.primary',
        z @$appBar, {
          title: 'Battle Decks'
          isFlat: true
          $topLeftButton: z @$buttonMenu, {color: colors.$tertiary900}
          $topRightButton: null # FIXME
        }

        z @$tabs,
          isBarFixed: false
          vDomKey: 'decks-' + if $sideEl then 'side' else 'noside'
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
      if $sideEl
        z '.secondary',
          $sideEl
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
