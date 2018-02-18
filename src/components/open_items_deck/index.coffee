z = require 'zorium'
_map = require 'lodash/map'
_some = require 'lodash/some'
_isEqual = require 'lodash/isEqual'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
require 'rxjs/add/operator/map'

Icon = require '../icon'
ItemOpen = require '../item_open'
Confetti = require '../confetti'
FlatButton = require '../flat_button'
SecondaryButton = require '../secondary_button'
FormatService = require '../../services/format'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

STARTING_ROTATION = 0
ROTATION_PER_ITEM = 2
SLIDE_OUT_TIME_MS = 300
SPREAD_DELAY_MS = 500
FLIP_DELAY_MS = 250
ITEM_PADDING_PX = 130

module.exports = class OpenItemsDeck
  constructor: ({@model, @items, @isDone, @isDeckSpread, backKey}) ->
    @$confetti = new Confetti()

    me = @model.user.getMe()
    @isDeckSpread ?= new RxBehaviorSubject false
    @isDone ?= new RxBehaviorSubject false

    @state = z.state
      me: me
      isDeckSpread: @isDeckSpread
      isVisible: false
      items: @items.map (items) =>
        _map items, (item) =>
          item: item
          $item: new ItemOpen {
            @model
            isBack: true
            backKey: backKey
            isLocked: false
            itemInfo: {item: item}
          }
      itemsSwiped: 0

  reset: =>
    @isDone.next false
    @isDeckSpread.next false
    @state.set isVisible: false, itemsSwiped: 0

  show: =>
    {items} = @state.getValue()

    @state.set isVisible: true

    if items?.length is 1
      @isDone.next true

    setTimeout =>
      @isDeckSpread.next true
      setTimeout =>
        items[items.length - 1]?.$item?.flip()
        .then =>
          @state.set isWaitingToFlip: false
      , FLIP_DELAY_MS
    , SPREAD_DELAY_MS

  beforeUnmount: =>
    @state.set
      itemsSwiped: 0
      isVisible: false

  swipeItem: =>
    {items, itemsSwiped, isWaitingToFlip} = @state.getValue()

    itemCount = items?.length
    if itemsSwiped + 1 is itemCount - 1
      @isDone.next true

    if not isWaitingToFlip and itemsSwiped < itemCount - 1
      @state.set
        itemsSwiped: itemsSwiped + 1
        isWaitingToFlip: true
      setTimeout =>
        items[itemCount - itemsSwiped - 2].$item.flip()
        .then =>
          @state.set
            isWaitingToFlip: false
      , SLIDE_OUT_TIME_MS

  render: (props = {}) =>
    {startingTranslateY, itemOpenHeightPx,
      startingScale, isAlignedBottom} = props

    {me, items, isVisible, isDeckSpread, itemsSwiped
      isWaitingToFlip} = @state.getValue()

    itemCount = items?.length

    itemOpenHeightPx ?= 322
    itemSizePx = itemOpenHeightPx - ITEM_PADDING_PX
    startingTranslateY ?= window?.innerHeight
    startingScale ?= 1
    translateX = -window?.innerWidth / 2 - itemSizePx / 2

    currentItem = if items \
                  then items[items.length - itemsSwiped - 1]
                  else null
    currentItemCirculating = if currentItem?.item \
                             then currentItem.item.circulating + 1
                             else null

    z '.z-open-items-deck', {
      className: z.classKebab {
        isVisible
        isDeckSpread
        isAlignedBottom
      }
    },
      if isVisible and currentItem?.item.rarity in ['rare', 'epic', 'legendary']
        confettiColors = config.CONFETTI_COLORS[currentItem?.item.rarity]
        if colors
          @$confetti.setColors confettiColors
        z '.confetti',
          @$confetti

      z '.items', {
        style:
          height: "#{itemOpenHeightPx}px" # FIXME: 130 is size of padding, etc.
      },
        z '.deck', {
          style:
            transform: if isVisible \
                   then 'translate(0, 0) scale(1, 1)'
                   else "translate(0, #{startingTranslateY}px) scale(#{startingScale}, #{startingScale})"
            webkitTransform: if isVisible \
                   then 'translate(0, 0)'
                   else "translate(0, #{startingTranslateY}px) scale(#{startingScale}, #{startingScale})"
        },
          _map items, ({$item, item}, i) =>
            isSlidingOut = itemsSwiped >= itemCount - i
            rotation = STARTING_ROTATION + ROTATION_PER_ITEM * i
            z '.item', {
              onclick: => @swipeItem i
              style:
                marginLeft: "-#{40 + itemSizePx / 2}px" # FIXME: 20px is padding
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
                sizePx: itemSizePx
              }
