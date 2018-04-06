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
Base = require '../base'
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

getItemSizeInfo = ({$$el, windowSize, breakpoint}) ->
  if breakpoint is 'desktop'
    info = {itemsPerRow: 6, itemMargin: 12}
  else if breakpoint is 'tablet'
    info = {itemsPerRow: 4, itemMargin: 6}
  else
    info = {itemsPerRow: 3, itemMargin: 6}
  offsetWidth = $$el?.offsetWidth or windowSize.contentWidth

  info.itemSize = (
    offsetWidth -
     X_PADDING_PX * 2 -
     (info.itemsPerRow - 1) * info.itemMargin * 2
   ) / info.itemsPerRow
  info

module.exports = class ItemList extends Base
  constructor: (options) ->
    {@model, @router, items, userItems, searchValue, groupKeyFilter, sortFn,
        isGrouped, group, @hideActions, @useRawCount, @showName,
        @showCounts} = options

    me = @model.user.getMe()
    isGrouped ?= true
    @showCounts ?= true
    searchValue ?= new RxBehaviorSubject ''
    groupKeyFilter ?= new RxBehaviorSubject null
    items ?= new RxBehaviorSubject null
    sortFn ?= (info) ->
      # items owned show first, then sorted by rarity
      ownedAmount = if info.count then 0 else 10
      ownedAmount + config.RARITIES.indexOf(info.item.rarity)

    @initialItemSizeInfo = getItemSizeInfo {
      windowSize: @model.window.getSizeVal()
      breakpoint: @model.window.getBreakpointVal()
    }
    @itemSizeInfo = new RxBehaviorSubject @initialItemSizeInfo

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
      isReady: false
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
    setSize = =>
      width = @$$el?.offsetWidth
      if width
        @itemSizeInfo.next getItemSizeInfo {
          @$$el
          windowSize: @model.window.getSizeVal()
          breakpoint: @model.window.getBreakpointVal()
        }
        setTimeout =>
          @state.set isReady: true
        , 0
      else if tries < maxTries
        tries += 1
        setTimeout setSize, retryTimeMs
      else
        @state.set isReady: true
    setSize()

  beforeUnmount: =>
    window.removeEventListener 'resize', @onResize
    @state.set isReady: false
    super()

  onResize: =>
    @itemSizeInfo.next getItemSizeInfo {
      @$$el
      windowSize: @model.window.getSizeVal()
      breakpoint: @model.window.getBreakpointVal()
    }

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
      isLocked = not @model.userItem.isOwnedByUserItemsAndItemKey(
        userItems, item.key
      )
      sizePx = @itemSizeInfo.map ({itemSize}) -> itemSize
      $el = @getCached$ "item-#{item.key}", ItemClass, {
        @model
        @router
        group
        @hideActions
        @useRawCount
        hasCount: @showCounts
        hasName: @showName
        isLocked: isLocked
        itemInfo: itemInfo
        sizePx: sizePx
      }
      $el.update {itemInfo, isLocked}

      return {
        info: itemInfo
        $el: $el
      }

  groupByRow: (items, {itemsPerRow}) ->
    rows = _chunk items, itemsPerRow
    _toArray rows

  render: ({onclick, isInactive, scrollTop, showName}) =>
    {me, itemGroups, itemSizeInfo, isDrawerOpen, drawerWidth, isReady,
      windowSize} = @state.getValue()

    {itemsPerRow, itemMargin, itemSize} = itemSizeInfo

    groupScrollTop = SEARCH_BAR_HEIGHT

    z '.z-item-list', {
      className: z.classKebab {isInactive, isReady}
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
              itemBlockHeight = items?[0]?.$el?.getHeight()
              if itemBlockHeight
                containerHeight = itemBlockHeight + itemMargin * 2
              else
                containerHeight = 0

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
                      defaultLocked: @showCounts is false
                      showName: showName
                      onclick: ->
                        onclick info
                      isHidden: isInactive
                    }
