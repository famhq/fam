z = require 'zorium'
_map = require 'lodash/map'
Rx = require 'rx-lite'

Icon = require '../icon'
PrimaryButton = require '../primary_button'
FlatButton = require '../flat_button'
ArenaPickerDialog = require '../arena_picker_dialog'
CardPickerDialog = require '../card_picker_dialog'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class DecksNew
  constructor: ({@model, @router, group}) ->
    @filters = [
      {
        title: 'Arena level'
        description: 'All arenas'
        $chevronIcon: new Icon()
        onclick: =>
          @overlay$.onNext @$arenaPickerDialog
      }
      {
        title: 'Decks with these cards'
        description: 'Ice Golem, Minions'
        $chevronIcon: new Icon()
        onclick: =>
          @overlay$.onNext @$cardPickerDialog
      }
      {
        title: 'Don\'t include these cards'
        description: 'Electro Wizard, Inferno Tower, +3 more...'
        $chevronIcon: new Icon()
        onclick: =>
          @overlay$.onNext @$cardPickerDialog
      }
    ]


    @overlay$ = new Rx.BehaviorSubject null

    @$arenaPickerDialog = new ArenaPickerDialog {@model, @overlay$}
    @$cardPickerDialog = new CardPickerDialog {@model, @overlay$}

    @$searchButton = new PrimaryButton()
    @$myDecksButton = new FlatButton()
    @$submitGuideButton = new FlatButton()

    @state = z.state {
      @overlay$
    }

  render: =>
    {overlay$} = @state.getValue()

    # unhighlighted is opac 0.12
    # start with all highlighted
    # tap one unhihglights all but one tapped


    z '.z-decks',
      z '.header-background'
      z '.content',
        z '.g-grid',
          z '.header', 'Find the perfect deck'
          z '.filters', [
            _map @filters, ({title, description, onclick, $chevronIcon}) ->
              z '.filter', {onclick},
                z '.info',
                  z '.title', title
                  z '.description', description
                z '.chevron',
                  z $chevronIcon,
                    icon: 'chevron-right'
                    isTouchTarget: false
                    color: colors.$primary500
            z '.search-button',
              z @$searchButton,
                text: 'Search decks & guides'
          ]
          z '.flat-button',
            z @$myDecksButton,
              text: 'Browse your decks'
              colors:
                cText: colors.$primary500
          z '.flat-button',
            z @$submitGuideButton,
              text: 'Submit a guide'
              colors:
                cText: colors.$primary500

      overlay$
