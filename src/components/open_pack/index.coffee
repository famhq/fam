z = require 'zorium'
_map = require 'lodash/map'
_some = require 'lodash/some'
_isEqual = require 'lodash/isEqual'

Icon = require '../icon'
Sticker = require '../sticker'
Confetti = require '../confetti'
PrimaryButton = require '../primary_button'
FormatService = require '../../services/format'
Ripple = require '../ripple'
colors = require '../../colors'

if window?
  require './index.styl'

REQUIRES_CONFETTI = [['legendary']]

STARTING_ROTATION = 0
ROTATION_PER_ITEM = 0
SLIDE_OUT_TIME_MS = 300
DECK_SPREAD_DELAY_MS = 0

module.exports = class OpenPack
  constructor: ({@model, @items, @onClose}) ->
    @$globeIcon = new Icon()
    @$cpIcon = new Icon()
    @$doneButton = new PrimaryButton()
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
          $item: new Sticker {
            @model
            isBack: true
            isLocked: false
            itemInfo: {item: item}
          }
      itemsSwiped: 0

  afterMount: =>
    setTimeout =>
      @$ripple.ripple({
        color: colors.$primary500
        isCenter: true
        fadeIn: true
      }).then =>
        @state.set
          isVisible: true
        setTimeout =>
          @state.set
            isDeckSpread: true
        , DECK_SPREAD_DELAY_MS
    , 0

  beforeUnmount: =>
    @state.set
      itemsSwiped: 0
      isVisible: false
      isDeckSpread: false

  render: ({pack}) =>
    {me, items, isVisible, isDeckSpread, itemsSwiped} = @state.getValue()

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
    isSpecialItem = _some REQUIRES_CONFETTI, (subTypes) ->
      _isEqual subTypes, currentItem?.item?.subTypes

    z '.z-open-pack', {
      className: z.classKebab {
        isVisible
        isDeckSpread
        isDoneVisible
      }
    },
      if isSpecialItem
        z '.confetti',
          @$confetti
      z @$ripple

      z '.content',
        z '.top-right',
          z '.circulating',
            z '.icon',
              z @$globeIcon,
                icon: 'globe'
                isTouchTarget: false
                color: colors.$tertiary200
            FormatService.number currentItemCirculating

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
                z '.image',
                  z $item, {
                    size: itemSize
                    onclick: =>
                      if itemsSwiped < itemCount - 1
                        @state.set itemsSwiped: itemCount - i
                  }
                z '.name', item.name
                z '.rarity', item.rarity

        z '.bottom',
          z '.action',
            z @$doneButton,
              text: 'Done'
              colors:
                c200: colors.$tertiary200
                c500: colors.$tertiary500
                c600: colors.$tertiary600
                c700: colors.$tertiary700
              onclick: =>
                @onClose()
          z '.tap-to-reveal',
            'Tap to reveal the next item'
