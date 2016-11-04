z = require 'zorium'
Rx = require 'rx-lite'
_ = require 'lodash'
_map = require 'lodash/collection/map'
_mapValues = require 'lodash/object/mapValues'
_isEmpty = require 'lodash/lang/isEmpty'
FloatingActionButton = require 'zorium-paper/floating_action_button'

config = require '../../config'
colors = require '../../colors'
Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
Decks = require '../../components/decks'
Tabs = require '../../components/tabs'
Icon = require '../../components/icon'

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

    @$recentDecks = new Decks {@model, @router, sort: 'recent', filter: 'mine'}
    @$popularDecks = new Decks {@model, @router, sort: 'popular'}

    @$tabs = new Tabs {@model}

  renderHead: => @$head

  render: =>
    z '.p-decks', {
      style:
        height: "#{window?.innerHeight}px"
    },
      z @$appBar, {
        title: 'Battle Decks'
        isFlat: true
        $topLeftButton: z @$buttonMenu, {color: colors.$primary900}
        $topRightButton: null # FIXME
      }

      z @$tabs,
        isBarFixed: false
        tabs: [
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
            @router.go '/newDeck'
