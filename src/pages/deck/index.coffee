z = require 'zorium'
Rx = require 'rx-lite'
_ = require 'lodash'
_map = require 'lodash/collection/map'
_mapValues = require 'lodash/object/mapValues'
_isEmpty = require 'lodash/lang/isEmpty'

config = require '../../config'
colors = require '../../colors'
Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
Deck = require '../../components/deck'
Spinner = require '../../components/spinner'
Icon = require '../../components/icon'

if window?
  require './index.styl'

module.exports = class DeckPage
  constructor: ({@model, requests, @router, serverData}) ->
    deck = requests.flatMapLatest ({route}) =>
      @model.clashRoyaleDeck.getById route.params.id

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: 'Deck'
        description: 'Deck'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@model, @router}
    @$deck = new Deck {@model, @router, deck}

    @state = z.state {deck}

  renderHead: => @$head

  render: =>
    {deck} = @state.getValue()

    z '.p-deck', {
      style:
        height: "#{window?.innerHeight}px"
    },
      z @$appBar, {
        title: deck?.name
        $topLeftButton: z @$buttonBack, {color: colors.$primary900}
        isFlat: true
        $topRightButton: null # FIXME
      }
      @$deck
