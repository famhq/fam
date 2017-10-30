z = require 'zorium'
moment = require 'moment'
_map = require 'lodash/map'
_isEmpty = require 'lodash/isEmpty'

colors = require '../../colors'
DeckCards = require '../deck_cards'
Base = require '../base'
Avatar = require '../avatar'
Spinner = require '../spinner'

if window?
  require './index.styl'

CARDS_PER_ROW = 4
PADDING = 16

module.exports = class DecksGuides extends Base
  constructor: ({@model, @router, sort, gameKey}) ->
    @$spinner = new Spinner()

    me = @model.user.getMe()
    guides = @model.thread.getAll({category: 'decks', sort})
    .map (guides) ->
      guides

    @state = z.state
      me: @model.user.getMe()
      windowSize: @model.window.getSize()
      gameKey: gameKey
      guides: guides.map (guides) =>
        _map guides, (guide) =>
          if guide.deck
            deck = guide.deck
            $deck = @getCached$ guide.id, DeckCards, {
              @model, @router, deck, cardsPerRow: 8
            }
          {
            guide
            $deck: $deck
            $avatar: new Avatar()
          }

  afterMount: (@$$el) => null

  render: =>
    {me, guides, windowSize, gameKey} = @state.getValue()

    cardWidth = (@$$el?.children?[0]?.offsetWidth - (PADDING * 2)) /
                  CARDS_PER_ROW

    z '.z-decks-guides',
      z '.guides', {
        # force scrollbar initially
        style:
          minHeight: "#{windowSize.height * 1.2}px"
      },
        if guides and _isEmpty guides
          z '.no-guides',
            @model.l.get 'deckGuides.noGuides'
        else if guides
          _map guides, ({guide, $deck, $avatar}) =>
            [
              @router.link z 'a.guide', {
                href: @router.get 'thread', {gameKey, id: guide.id}
              },
                z '.g-grid',
                  z '.author',
                    z '.avatar',
                      z $avatar, {user: guide?.creator, size: '20px'}
                    z '.name', @model.user.getDisplayName guide?.creator
                    z 'span', innerHTML: '&nbsp;&middot;&nbsp;'
                    z '.time',
                      if guide.addTime
                      then moment(guide.addTime).fromNowModified()
                      else '...'
                  z '.title', guide.title
                  z '.summary', guide.summary
                  z '.deck',
                    z $deck, {maxCardWidth: 45}
              z '.divider'
            ]
        else
          @$spinner
