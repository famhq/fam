z = require 'zorium'
_isEmpty = require 'lodash/isEmpty'
_map = require 'lodash/map'
_find = require 'lodash/find'
_sum = require 'lodash/sum'
_startCase = require 'lodash/startCase'
_snakeCase = require 'lodash/snakeCase'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

FormatService = require '../../services/format'
AppBar = require '../app_bar'
PrimaryButton = require '../primary_button'
SecondaryButton = require '../secondary_button'
ButtonBack = require '../button_back'
ItemOpen = require '../item_open'
OpenItemsDeck = require '../open_items_deck'
Spinner = require '../spinner'
Icon = require '../icon'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

###
rm text, drop chest to bottom of screen
put items up top like open_pack / spread deck (or do cr style)


###

CHEST_MOVE_ANIMATION_MS = 1000
CHEST_OPEN_ANIMATION_MS = 500
ITEM_OPEN_HEIGHT_PX = 300
CHEST_SIZE_PX = 300

module.exports = class OpenChest
  constructor: (options) ->
    {@model, @router, infoStreams, @overlay$, group} = options

    @itemInfo = infoStreams.switch()
    @openItems = new RxBehaviorSubject null
    isDone = new RxBehaviorSubject false

    @$appBar = new AppBar {@model, @router}
    @$backButton = new ButtonBack {@router, @model}
    @$fireIcon = new Icon()
    @$actionButton = new PrimaryButton()
    @$doneButton = new SecondaryButton()
    @$spinner = new Spinner()
    @$openItemsDeck = new OpenItemsDeck {
      @model
      items: @openItems
      isDone: isDone
      backKey: @itemInfo.map (itemInfo) ->
        itemInfo?.item?.data?.backKey
    }

    @me = @model.user.getMe()

    if window?
      @itemInfo = @itemInfo.map (itemInfo) =>
        @preloadImages itemInfo
        itemInfo

    @state = z.state
      me: @me
      isLoading: false
      info: @itemInfo
      openItems: @openItems
      userItems: @model.userItem.getAll()
      isChestOpened: false
      chestPosition: null
      isDone: isDone
      group: group

  afterMount: (@$$el) => null

  beforeUnmount: =>
    @state.set chestPosition: null
    @openItems.next null
    @reset()

  preloadImages: (itemInfo) ->
    if itemInfo
      {item} = itemInfo
      images = []
      filenameParts = ['large']
      images.push config.CDN_URL + '/items/chests/' +
                      "#{item.key}_#{filenameParts.join('_')}.png"
      filenameParts = ['open', 'large']
      images.push config.CDN_URL + '/items/chests/' +
                      "#{item.key}_#{filenameParts.join('_')}.png"

      _map images, (imageSrc) ->
        image = new Image()
        image.src = imageSrc

  reset: =>
    @$openItemsDeck.reset()
    @state.set isChestOpened: false, isChestOpening: false

  _openChest: =>
    {info, group, isDone, chestPosition} = @state.getValue()

    if isDone
      @reset()

    item = info?.item

    unless chestPosition
      $$chest = @$$el.querySelector('.chest')
      boundingClientRect = $$chest.getBoundingClientRect()
      @state.set chestPosition: boundingClientRect

    @model.userItem.openByItemKey item.key, {groupId: group.id}
    .then (items) =>
      @openItems.next items
      setTimeout =>
        setTimeout =>
          @state.set isChestOpened: true
          @$openItemsDeck.show()
        , CHEST_OPEN_ANIMATION_MS / 2
        @state.set isChestOpening: true
      , CHEST_MOVE_ANIMATION_MS

  render: =>
    {me, info, userItems, isLoading, group, chestPosition
      openItems, isChestOpened, isChestOpening, isDone} = @state.getValue()

    item = info?.item
    hasChest = info?.count > 0
    keyRequired = item?.data?.keyRequired
    keyUserItem = keyRequired and _find userItems, {itemKey: keyRequired}
    hasKey = keyUserItem?.count > 0
    hasOpenedItems = not _isEmpty openItems

    if chestPosition
      desiredChestPosition = window?.innerHeight / 2# + ITEM_OPEN_HEIGHT_PX / 2
      chestTranslateY = desiredChestPosition - chestPosition.top
      chestPositionTop = chestPosition?.top
      chestPositionLeft = chestPosition?.left
      transformStr = "translate(0, #{chestTranslateY}px)"
    else
      chestPositionTop = 0
      chestPositionLeft = 0
      transformStr = 'translate(0, 0)'

    if item
      filenameParts = ['large']
      chestImageUrl = config.CDN_URL + '/items/chests/' +
                      "#{item.key}_#{filenameParts.join('_')}.png"
      filenameParts = ['open', 'large']
      openedChestImageUrl = config.CDN_URL + '/items/chests/' +
                      "#{item.key}_#{filenameParts.join('_')}.png"


    z '.z-open-chest', {
      className: z.classKebab {
        hasOpenedItems, isDone, isChestOpened, isChestOpening
      }
    },
      z '.app-bar',
        z @$appBar,
          $topLeftButton: z @$backButton, {
            color: colors.$header500Icon
            onclick: =>
              @overlay$.next null
          }
          title: info?.name
      if not item
        @$spinner
      else
        z '.content',
          z '.g-grid',
            z '.items-deck',
              if hasOpenedItems
                z @$openItemsDeck, {
                  itemOpenHeightPx: ITEM_OPEN_HEIGHT_PX
                  startingTranslateY: ITEM_OPEN_HEIGHT_PX / 2 +
                                        CHEST_SIZE_PX / 2
                  startingScale: 0.4
                  isAlignedBottom: true
                }
            # if hasOpenedItems
            #   z '.items',
            #     z '.deck',
            #     _map $openedItems, ($item) ->
            #       z '.item', $item

            z '.chest-wrapper',
              z '.chest', {
                style:
                  transform: transformStr
                  webkitTransform: transformStr
                  position: if chestPosition then 'absolute' else 'relative'
                  top: "#{chestPositionTop}px"
                  left: "#{chestPositionLeft}px"
              },
                z '.chest-image', {
                  style:
                    backgroundImage: if isChestOpened \
                                     then "url(#{openedChestImageUrl})"
                                     else "url(#{chestImageUrl})"
                  onclick: =>
                    @$openItemsDeck.swipeItem()
                }
            z '.info',
              z '.odds',
                _map item?.data?.odds, ({rarity, odds}) ->
                  z '.odd',
                    z '.rarity', _startCase rarity
                    z '.odds', FormatService.percentage odds

            z '.action',
              if isDone
                z @$doneButton,
                  $content: @model.l.get 'general.done'
                  onclick: =>
                    @overlay$.next null

              if hasKey and hasChest
                z @$actionButton,
                  $content: if isLoading \
                            then @model.l.get 'general.loading'
                            else "#{@model.l.get 'openChest.useKey'} " + \
                                  "(#{keyUserItem.count})"
                  onclick: @_openChest
              else if hasChest and not isDone
                [
                  z '.text', @model.l.get 'openChest.needKeys'
                  z @$actionButton,
                    $content: @model.l.get 'general.done'
                    onclick: =>
                      @overlay$.next null
                ]
              else if not isDone
                [
                  z '.text', @model.l.get 'openChest.needChest'
                  z @$actionButton,
                    $content: @model.l.get 'general.done'
                    onclick: =>
                      @overlay$.next null
                ]
