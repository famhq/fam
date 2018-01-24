z = require 'zorium'
_map = require 'lodash/map'
_some = require 'lodash/some'
_isEqual = require 'lodash/isEqual'
require 'rxjs/add/operator/map'

Icon = require '../icon'
StickerOpen = require '../sticker_open'
Confetti = require '../confetti'
SecondaryButton = require '../secondary_button'
FormatService = require '../../services/format'
Ripple = require '../ripple'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

STARTING_ROTATION = 0
ROTATION_PER_ITEM = 2
SLIDE_OUT_TIME_MS = 300
SPREAD_DELAY_MS = 1000
FLIP_DELAY_MS = 250

module.exports = class OpenPack
  constructor: ({@model, @items, @onClose, pack}) ->
    @$globeIcon = new Icon()
    @$cpIcon = new Icon()
    @$doneButton = new SecondaryButton()
    @$ripple = new Ripple()
    @$confetti = new Confetti()

    me = @model.user.getMe()

    @state = z.state
      me: me
      isVisible: false
      isDeckSpread: false
      items: @items.map (items) =>
        _map items, (item) =>
          item: item
          $item: new StickerOpen {
            @model
            isBack: true
            backKey: pack?.data.backKey
            isLocked: false
            itemInfo: {item: item}
          }
      itemsSwiped: 0

  afterMount: =>
    {items} = @state.getValue()

    setTimeout =>
      @$ripple.ripple({
        color: colors.$primary500
        isCenter: true
        fadeIn: true
      }).then =>
        @state.set
          isVisible: true
        setTimeout =>
          @state.set {isDeckSpread: true}
          setTimeout =>
            items[items.length - 1]?.$item?.flip()
            .then =>
              @state.set isWaitingToFlip: false
          , FLIP_DELAY_MS
        , SPREAD_DELAY_MS
    , 0

  beforeUnmount: =>
    @state.set
      itemsSwiped: 0
      isVisible: false
      isDeckSpread: false

  buyAnotherPack: -> null # TODO

  render: =>
    {me, items, isVisible, isDeckSpread, itemsSwiped,
      isWaitingToFlip} = @state.getValue()

    itemCount = items?.length

    isDoneVisible = itemsSwiped is itemCount - 1

    itemSize = 192
    translateX = -window?.innerWidth / 2 - itemSize / 2

    currentItem = if items \
                  then items[items.length - itemsSwiped - 1]
                  else null
    currentItemCirculating = if currentItem?.item \
                             then currentItem.item.circulating + 1
                             else null

    z '.z-open-pack', {
      className: z.classKebab {
        isVisible
        isDeckSpread
        isDoneVisible
      }
    },
      if isVisible and currentItem?.item.rarity isnt 'common'
        confettiColors = config.CONFETTI_COLORS[currentItem?.item.rarity]
        if colors
          @$confetti.setColors confettiColors
        z '.confetti',
          @$confetti
      z @$ripple

      z '.content',
        # z '.top-right',
        #   z '.circulating',
        #     z '.icon',
        #       z @$globeIcon,
        #         icon: 'globe'
        #         isTouchTarget: false
        #         color: colors.$tertiary200
        #     FormatService.number currentItemCirculating

        z '.items', {
          style:
            height: "#{itemSize + 130}px" # FIXME: 130 is size of padding, etc.
        },
          z '.deck', {
            style:
              transform: if isVisible \
                         then 'translate(0, 0)'
                         else "translate(0, #{window?.innerHeight}px)"
              webkitTransform: if isVisible \
                               then 'translate(0, 0)'
                               else "translate(0, #{window?.innerHeight}px)"
          },
            _map items, ({$item, item}, i) =>
              isSlidingOut = itemsSwiped >= itemCount - i
              rotation = STARTING_ROTATION + ROTATION_PER_ITEM * i
              z '.item', {
                onclick: =>
                  if not isWaitingToFlip and itemsSwiped < itemCount - 1
                    @state.set
                      itemsSwiped: itemCount - i# + 1
                      isWaitingToFlip: true
                    setTimeout =>
                      items[i - 1].$item.flip()
                      .then =>
                        @state.set
                          isWaitingToFlip: false
                    , SLIDE_OUT_TIME_MS
                style:
                  marginLeft: "-#{40 + itemSize / 2}px" # FIXME: 20px is padding
                  transform: if isSlidingOut \
                             then "translate(#{translateX}px, 0) " + \
                                  'rotate(0deg)' \
                             else if isDeckSpread \
                             then  "rotate(#{rotation}deg)"
                             else 'rotate(0deg)'
                  webkitTransform: if isSlidingOut \
                                   then "translate(#{translateX}px, 0) " + \
                                        'rotate(0deg)' \
                                   else if isDeckSpread \
                                   then "rotate(#{rotation}deg)"
                                   else 'rotate(0deg)'
                  pointerEvents: if isSlidingOut then 'none' else 'auto'
              },
                z $item, {
                  sizePx: itemSize
                }

        z '.bottom',
          z '.action',
            z @$doneButton,
              text: @model.l.get 'general.done'
              onclick: =>
                @onClose()
          z '.tap-to-reveal',
            'Tap to reveal the next item'
