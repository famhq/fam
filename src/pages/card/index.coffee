z = require 'zorium'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
CardInfo = require '../../components/card_info'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class CardPage
  constructor: ({@model, requests, @router, serverData}) ->
    card = requests.flatMapLatest ({route}) =>
      @model.clashRoyaleCard.getById route.params.id

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: 'Card'
        description: 'Card'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@model, @router}
    @$cardInfo = new CardInfo {@model, @router, card}

    @state = z.state
      card: card
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {card, windowSize} = @state.getValue()

    z '.p-card', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: card?.name
        $topLeftButton: z @$buttonBack, {color: colors.$tertiary900}
        isFlat: true
      }
      @$cardInfo
