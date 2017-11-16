z = require 'zorium'
_sum = require 'lodash/sum'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_sample = require 'lodash/sample'
_groupBy = require 'lodash/groupBy'
_clone = require 'lodash/clone'
_values = require 'lodash/values'
_isEmpty = require 'lodash/isEmpty'
_startCase = require 'lodash/startCase'
_takeRight = require 'lodash/takeRight'
_snakeCase = require 'lodash/snakeCase'

config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ChestSimulator
  constructor: ({@model, chest, cards, @showAdAfter, @onClose}) ->
    chest ?= 'legendary'

    @preloadImages cards, chest

    @state = z.state
      chest: chest
      cards: cards
      cardsLeft: cards
      isOpened: false
      isClicked: false

  afterMount: (@$$el) =>
    setTimeout =>
      @state.set isOpened: true, isClicked: true
      setTimeout =>
        @state.set isClicked: false
      , 500
    , 1000

  preloadImages: (cards, chest) ->
    i = new Image()
    i.src = "#{config.CDN_URL}/chests/#{_snakeCase(chest)}_opened.png"
    backs = ['back', 'common_back', 'rare_back', 'epic_back', 'legendary_back']
    _map backs, (back) ->
      i = new Image()
      i.src = "#{config.CDN_URL}/cards/#{back}.png"
    _map cards, (card) ->
      if card.card.key in ['gold', 'gems']
        cardImage = "#{config.CDN_URL}/clash_royale/#{card.card.key}_card.png"
      else
        cardImage = "#{config.CDN_URL}/cards/#{card.card.key}.png"
      i = new Image()
      i.src = cardImage

  onclick: =>
    {cardsLeft, isOpened, isClicked} = @state.getValue()
    if not isOpened or isClicked
      return
    isDone = _isEmpty cardsLeft

    if isDone
      @onClose()
    else
      cardsLeft = _takeRight cardsLeft, (cardsLeft.length - 1)
      @state.set
        cardsLeft: cardsLeft
        isClicked: not _isEmpty cardsLeft
      setTimeout =>
        @state.set isClicked: false
      , 500

  render: =>
    {chest, cards, cardsLeft, isOpened, isClicked} = @state.getValue()

    card = cardsLeft[0]
    isDone = _isEmpty cardsLeft

    z '.z-simulator', {
      onclick: @onclick
      className: z.classKebab {isDone, isOpened, isClicked}
    },
      unless isDone
        cardType = @model.clashRoyaleCard.getNameTranslation(card.type) +
                    ' ' +
                    @model.l.get 'simulator.card'
        if card.card.key in ['gold', 'gems']
          cardImage = "#{config.CDN_URL}/clash_royale/#{card.card.key}_card.png"
        else
          cardImage = "#{config.CDN_URL}/cards/#{card.card.key}.png"

        z '.top',
          z '.card', {
            className: z.classKebab {"is#{_startCase(card.type)}": true}
            style:
              backgroundImage: "url(#{cardImage})"
          },
            if card.card.key in ['gold', 'gems']
              "+#{card.count}"
            else
              "x#{card.count}"

          z '.info',
            z '.name', @model.clashRoyaleCard.getNameTranslation card.card.key
            z '.description', {
              className: z.classKebab {"is#{_startCase(card.type)}": true}
              dataset:
                text: cardType
            },
              cardType
            # z '.your-gems', 'Your gems'

      z '.chest', {
        style:
          backgroundImage:
            if isOpened
              "url(#{config.CDN_URL}/chests/#{_snakeCase(chest)}_opened.png)"
            else
              "url(#{config.CDN_URL}/chests/#{_snakeCase(chest)}_closed.png)"
      },
        unless isDone
          z '.cards-left',
            if isClicked or not isOpened
              cardsLeft.length
            else
              cardsLeft.length - 1
      if isDone
        z '.bottom',
          z '.you-got', @model.l.get 'simulator.youGot'
          z '.cards',
            _map cards, (card) ->
              if card.card.key in ['gold', 'gems']
                cardImage = "#{config.CDN_URL}/clash_royale/#{card.card.key}_card.png"
              else
                cardImage = "#{config.CDN_URL}/cards/#{card.card.key}.png"
              z '.card', {
                style:
                  backgroundImage: "url(#{cardImage})"
              },
                if card.card.key in ['gold', 'gems']
                  "+#{card.count}"
                else
                  "x#{card.count}"
          if @showAdAfter
            z '.ad-coming',
              @model.l.get 'simulator.adIncoming'
