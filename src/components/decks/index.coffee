z = require 'zorium'
Rx = require 'rx-lite'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
DeckList = require '../../components/deck_list'
DecksGuides = require '../../components/decks_guides'
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

    @$decksGuides = new DecksGuides {@model, @router, sort: 'popular'}
    @$recentDecks = new DeckList {
      @model, @router, sort: 'recent', filter: 'mine'
    }
    @$popularDecks = new DeckList {@model, @router, sort: 'popular'}

    selectedIndex = new Rx.BehaviorSubject 0
    @$tabs = new Tabs {@model, selectedIndex}

    @$popularIcon = new Icon()
    @$guidesIcon = new Icon()
    @$decksIcon = new Icon()

    @$cachedThread = null

    @state = z.state
      selectedIndex: selectedIndex
      me: @model.user.getMe()
      $sideEl: thread?.map (threadVal) =>
        console.log 'tval', threadVal
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
              $menuIcon: @$guidesIcon
              menuIconName: 'compass'
              $menuText: 'Guides'
              $el: @$decksGuides
            }
            {
              $menuIcon: @$popularIcon
              menuIconName: 'star'
              $menuText: 'Popular Decks'
              $el: @$popularDecks
            }
            {
              $menuIcon: @$decksIcon
              menuIconName: 'decks'
              $menuText: 'My Decks'
              $el: @$recentDecks
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
