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
ItemBlock = require '../item_block'
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

getItemSizeInfo = ($$el) ->
  if window?
    # TODO: json file with these vars, stylus uses this
    if window.matchMedia('(min-width: 840px)').matches
      info = {itemsPerRow: 6, itemMargin: 12}
    else if window.matchMedia('(min-width: 480px)').matches
      info = {itemsPerRow: 4, itemMargin: 6}
    else
      info = {itemsPerRow: 3, itemMargin: 6}
    if $$el?.offsetWidth
      info.itemSize = ($$el.offsetWidth -
                   X_PADDING_PX * 2 -
                   (info.itemsPerRow - 1) * info.itemMargin * 2
                   ) / info.itemsPerRow
    else
      info.itemSize = 114
    info
  else
    {itemsPerRow: DEFAULT_ITEMS_PER_ROW, itemMargin: 0, itemSize: 114}

module.exports = class ItemList
  constructor: (options) ->
    {@model, @router, items, userItems, searchValue, groupKeyFilter, sortFn,
        isGrouped, group, @hideActions, @useRawCount} = options

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
    itemGroups = listData.map (vals) =>
      [items, userItems, searchValue, groupKeyFilter, itemSizeInfo] = vals
      filteredItems = @filter items, {searchValue, groupKeyFilter}
      itemGroups = @group filteredItems
      itemGroups = _map itemGroups, (items, type) ->
        {items, type}
      itemGroups = _sortBy itemGroups, 'type'
      return _map itemGroups, ({items, type}) =>
        sortedItems = @sort items, sortFn
        bundledItems = @bundle sortedItems, {userItems, group}
        {itemsPerRow} = itemSizeInfo
        groupedItems = @groupByRow bundledItems, {itemsPerRow}
        {type, items: groupedItems}

    @$spinner = new Spinner()

    @state = z.state
      itemSizeInfo: @itemSizeInfo
      itemGroups: itemGroups
      isDrawerOpen: @model.drawer.isOpen()
      drawerWidth: @model.window.getDrawerWidth()
      me: me
      userItems: userItems
      windowSize: @model.window.getSize()

  afterMount: (@$$el) =>
    window.addEventListener 'resize', @onResize
    # TODO / HACKY: for some reason offsetWidth is 0 on initial load
    tries = 0
    maxTries = 5
    retryTimeMs = 200
    $$row = @$$el.querySelector '.row'
    setSize = =>
      width = @$$el?.offsetWidth
      if width
        @itemSizeInfo.next getItemSizeInfo @$$el
      else if tries < maxTries
        tries += 1
        setTimeout setSize, retryTimeMs
    setSize()

  beforeUnmount: =>
    window.removeEventListener 'resize', @onResize

  onResize: =>
    @itemSizeInfo.next getItemSizeInfo @$$el

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
        item.groupKey is groupKeyFilter
    items

  group: (items) ->
    _groupBy items, ({item}) ->
      itemType = item.type
      if itemType in ['coin', 'scratch', 'key', 'chest']
        itemType = 'consumable'
      itemType

  sort: (items, sortFn) ->
    _sortBy items, sortFn

  bundle: (items, {userItems, group}) =>
    _map items, (itemInfo) =>
      item = itemInfo.item
      ItemClass = if item.type is 'sticker' \
                  then StickerBlock
                  else ItemBlock
      $el = new ItemClass {
        @model
        @router
        group
        @hideActions
        @useRawCount
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

  render: ({onclick, isInactive, scrollTop, showCounts}) =>
    {me, itemGroups, itemSizeInfo, isDrawerOpen, drawerWidth,
      windowSize} = @state.getValue()

    {itemsPerRow, itemMargin, itemSize} = itemSizeInfo
    showCounts ?= true

    containerHeight = itemSize + COUNT_HEIGHT + itemMargin * 2

    groupScrollTop = SEARCH_BAR_HEIGHT

    z '.z-item-list', {
      className: z.classKebab {isInactive}
    },
      if itemGroups?.length is 0 or
          itemGroups?[0]?.length is 0
        z '.no-items', @model.l.get 'itemList.empty'
      else if not itemGroups or not itemGroups?.length
        @$spinner
      else
        _map itemGroups, (itemGroup) ->
          z '.group',
            z '.title', itemGroup.type
            _map itemGroup.items, (items, rowIndex) ->
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
                    className: z.classKebab {hasOnClick: Boolean onclick}
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
                      onclick: ->
                        onclick info
                      isHidden: isInactive
                    }
