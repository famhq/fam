z = require 'zorium'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_sortBy = require 'lodash/sortBy'
_groupBy = require 'lodash/groupBy'
_chunk = require 'lodash/chunk'
_toArray = require 'lodash/toArray'
_reduce = require 'lodash/reduce'
_sum = require 'lodash/sum'
_cloneDeep = require 'lodash/cloneDeep'
_flattenDeep = require 'lodash/flattenDeep'
_defaults = require 'lodash/defaults'
_mapValues = require 'lodash/mapValues'
_take = require 'lodash/take'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/combineLatest'
require 'rxjs/add/operator/map'

StickerBlock = require '../sticker_block'
Icon = require '../icon'
Spinner = require '../spinner'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

X_PADDING_PX = 8
DEFAULT_ITEMS_PER_ROW = 3
SEARCH_BAR_HEIGHT = 56
GROUP_TITLE_HEIGHT = 48
GROUP_MARGIN_BOTTOM = 8
COUNT_HEIGHT = 20
SEARCH_DEBOUNCE = 300
# TODO: json file with these vars, stylus uses this
MAX_CONTENT_WIDTH = 1280

getItemSizeInfo = ->
  if window?
    # TODO: json file with these vars, stylus uses this
    if window.matchMedia('(min-width: 840px)').matches
      {itemsPerRow: 6, itemMargin: 12}
    else if window.matchMedia('(min-width: 480px)').matches
      {itemsPerRow: 4, itemMargin: 6}
    else
      {itemsPerRow: 3, itemMargin: 6}
  else
    {itemsPerRow: DEFAULT_ITEMS_PER_ROW, itemMargin: 0}

module.exports = class ItemList
  constructor: (options) ->
    {@model, @router, items, userItems, searchValue, groupKeyFilter, sortFn,
        isGrouped} = options

    me = @model.user.getMe()
    isGrouped ?= true
    searchValue ?= new RxBehaviorSubject ''
    groupKeyFilter ?= new RxBehaviorSubject null
    items ?= new RxBehaviorSubject null
    sortFn ?= (info) ->
      # items owned show first, then sorted by rarity
      ownedAmount = if info.count then 0 else 10
      ownedAmount + config.RARITIES.indexOf(info.item.rarity)

    @itemSizeInfo = new RxBehaviorSubject getItemSizeInfo()
    listData = RxObservable.combineLatest(
      items
      userItems
      searchValue
      groupKeyFilter
      @itemSizeInfo
      (vals...) -> vals
    )
    rowsOfItems = listData.map (vals) =>
      [items, userItems, searchValue, groupKeyFilter, itemSizeInfo] = vals
      filteredItems = @filter items, {searchValue, groupKeyFilter}
      groupedItems = filteredItems
      sortedItems = @sort groupedItems, sortFn
      bundledItems = @bundle sortedItems, {userItems}
      {itemsPerRow} = itemSizeInfo
      rowsOfItems = @groupByRow bundledItems, {itemsPerRow}
      return rowsOfItems

    @$spinner = new Spinner()

    @state = z.state
      itemSizeInfo: @itemSizeInfo
      rowsOfItems: rowsOfItems
      me: me
      userItems: userItems
      windowSize: @model.window.getSize()

  afterMount: =>
    window.addEventListener 'resize', @onResize
    @itemSizeInfo.next getItemSizeInfo()

  beforeUnmount: =>
    window.removeEventListener 'resize', @onResize

  onResize: =>
    @itemSizeInfo.next getItemSizeInfo()

  filter: (items, {searchValue, groupKeyFilter}) ->
    if searchValue
      items = _filter items, ({item}) ->
        {name, type, subType, subTypes} = item
        subTypesStr = subTypes?.join(',')
        "#{name},#{type},#{subType},#{subTypesStr}".match(
          new RegExp searchValue, 'ig'
        )
    if groupKeyFilter and groupKeyFilter isnt 'All'
      items = _filter items, ({item}) ->
        item.gameKey is groupKeyFilter
    items

  sort: (items, sortFn) ->
    _sortBy items, sortFn

  bundle: (items, {userItems}) =>
    _map items, (itemInfo) =>
      item = itemInfo.item
      $el = new StickerBlock {
        @model
        @router
        isLocked: not @model.userItem.isOwnedByUserItemsAndItemKey(
          userItems, item.key
        )
        itemInfo: itemInfo
      }

      return {
        info: itemInfo
        $el: $el
      }

  groupByRow: (items, {itemsPerRow}) ->
    rows = _chunk items, itemsPerRow
    _toArray rows

  render: ({onclick, isInactive, scrollTop, showCounts, xPadding, maxRows}) =>
    {me, rowsOfItems, itemSizeInfo, windowSize} = @state.getValue()

    {itemsPerRow, itemMargin} = itemSizeInfo
    xPadding ?= X_PADDING_PX
    showCounts ?= true

    contentWidth = windowSize?.contentWidth or 320

    if window?
      itemSize = (contentWidth -
                   xPadding * 2 -
                   (itemsPerRow - 1) * itemMargin * 2
                   ) / itemsPerRow
    else
      itemMargin = 0
      itemSize = 114

    itemContainerHeight = itemSize + COUNT_HEIGHT + itemMargin * 2

    groupScrollTop = SEARCH_BAR_HEIGHT

    if maxRows
      rowsOfItems = _take rowsOfItems, maxRows

    z '.z-item-list', {
      className: z.classKebab {isInactive}
    },
      if rowsOfItems?.length is 0 or rowsOfItems?[0]?.length is 0
        z '.g-grid',
          z '.no-items', @model.l.get 'itemList.empty'
      else if not rowsOfItems or not rowsOfItems.length
        z '.g-grid',
          @$spinner
      else
        rows = rowsOfItems.length
        containerHeight = itemContainerHeight
        z '.g-grid',
          _map rowsOfItems, (items, rowIndex) ->
            # 2 * is for extra buffer room. also the
            # calculation seems to get
            # less accurate the futher page is scrolled
            isRowVisible = not scrollTop? or
               (groupScrollTop >= scrollTop - 2 * containerHeight and
               groupScrollTop < scrollTop + window?.innerHeight)
            groupScrollTop += containerHeight

            z '.row', {
              className: z.classKebab {isVisible: isRowVisible}
              style:
                height: "#{containerHeight}px"
            },
              _map items, ({info, $el}, itemIndex) ->
                z '.item', {
                  style:
                    maxWidth: "#{Math.floor(100 / itemsPerRow)}%"
                    marginRight: if itemIndex isnt items.length - 1 \
                                 then "#{itemMargin * 2}px"
                                 else 0
                    marginBottom: "#{itemMargin * 2}px"
                },
                  z $el, {
                    sizePx: if info?.item then itemSize else null
                    defaultLocked: showCounts is false
                    onclick: onclick
                    isHidden: isInactive
                  }
