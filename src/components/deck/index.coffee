z = require 'zorium'

DeckInfo = require '../deck_info'
DeckGuides = require '../deck_guides'
Icon = require '../icon'
Tabs = require '../tabs'
PrimaryButton = require '../primary_button'

if window?
  require './index.styl'

module.exports = class Deck
  constructor: ({@model, @router, deck, gameKey}) ->
    me = @model.user.getMe()

    @$infoIcon = new Icon()
    @$guidesIcon = new Icon()

    @$deckInfo = new DeckInfo {@model, @router, deck}
    @$deckGuides = new DeckGuides {@model, @router, deck, gameKey}
    @$tabs = new Tabs {@model}

    @state = z.state
      me: me
      deck: deck

  render: =>
    {me, deck, isSetDeckLoading} = @state.getValue()

    totalMatches = (deck?.wins + deck?.losses) or 1

    z '.z-deck',
      z @$tabs,
        isBarFixed: false
        barStyle: 'primary'
        tabs: [
          {
            $menuIcon: @$infoIcon
            menuIconName: 'info'
            $menuText: 'Info'
            $el: @$deckInfo
          }
          {
            $menuIcon: @$guidesIcon
            menuIconName: 'compass'
            $menuText: 'Guides'
            $el: @$deckGuides
          }
        ]
