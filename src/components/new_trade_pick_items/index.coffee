z = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_sortBy = require 'lodash/sortBy'
_keys = require 'lodash/keys'
_groupBy = require 'lodash/groupBy'
_startCase = require 'lodash/startCase'
_debounce = require 'lodash/debounce'
_isEmpty = require 'lodash/isEmpty'

config = require '../../config'
colors = require '../../colors'
Input = require '../input'
Dialog = require '../dialog'
Button = require '../button'
FormatService = require '../../services/format'
ItemService = require '../../services/item'
Icon = require '../icon'
Spinner = require '../spinner'
Item = require '../item'
Sticker = require '../sticker'
ItemList = require '../item_list'
SearchInput = require '../search_input'
TapTabs = require '../tap_tabs'
SecondaryButton = require '../secondary_button'

if window?
  require './index.styl'

ADDED_CARD_WIDTH = 58
TOP_HEIGHT_PX = 168
MIN_CARD_IDS_TO_TRADE = 20
SCROLL_DEBOUNCE_MS = 50

module.exports = class TradePickItems
  constructor: (options) ->
    {@model, @addedItemsSteams, items, toUserItems, otherUserItems,
        type, isUnlimited} = options

    @selectedPage = new RxBehaviorSubject 'unfiltered'
    @$tapTabs = new TapTabs {@selectedPage}

    itemsAndSelectedPageAndOtherUserItemKeys = RxObservable.combineLatest(
      items
      @selectedPage
      otherUserItems.map (userItems) ->
        _map userItems, ({itemKey}) -> itemKey
      (vals...) ->
        vals
    )

    @searchValue = new RxBehaviorSubject ''
    @groupIdFilter = new RxBehaviorSubject null
    @$searchInput = new SearchInput {@model, @searchValue}
    @$filterButton = new SecondaryButton()
    @$filterIcon = new Icon()

    items = itemsAndSelectedPageAndOtherUserItemKeys.map ([
      items, selectedPage, otherUserItemKeys
    ]) ->
      if selectedPage is 'filtered'
        _filter items, (item) ->
          otherUserItemKeys.indexOf(item.itemKey) is -1
      else
        items

    @$itemList = new ItemList {
      @model
      @searchValue
      @groupIdFilter
      items
      userItems: toUserItems
      useRawCount: true
      hideActions: true
    }
    @$minusIcon = new Icon()
    @$plusIcon = new Icon()
    @$filterDialog = new Dialog()
    @$cancelFilterButton = new Button()
    @$setFilterButton = new Button()

    me = @model.user.getMe()

    addedItems = @addedItemsSteams.switch()

    addedItemAndMe = RxObservable.combineLatest(
      addedItems
      me
      (vals...) -> vals
    )

    @debounceScroll = _debounce @onScroll, SCROLL_DEBOUNCE_MS

    @state = z.state
      me: me
      type: type
      isUnlimited: isUnlimited
      isFilterDialogVisible: false
      selectedPage: @selectedPage
      checkedItemGameKeyFilter: 'All'
      scrollTop: 0
      toUserItems: toUserItems
      addedItems: addedItems
      groupIds: items.map (items) ->
        types = _sortBy _keys _groupBy items, ({item}) -> item.groupId
        types.unshift 'All'
        types
      addedItemsWithComponents: addedItemAndMe.map ([addedItems, me]) =>
        _map addedItems, (itemInfo) =>
          ItemClass = if itemInfo.item.type is 'sticker' \
                      then Sticker
                      else Item
          {
            itemInfo: itemInfo
            $el: new ItemClass {
              @model
              isLocked: not @model.userItem.isOwnedByUserItemsAndItemKey(
                toUserItems, itemInfo.item.key
              )
              useRawCount: true
              itemInfo: itemInfo
            }
          }

  afterMount: (@$$el) =>
    @$$el?.querySelector('.items-container')?.addEventListener(
      'scroll', @debounceScroll
    )

  beforeUnmount: =>
    @$$el?.querySelector('.items-container')?.removeEventListener(
      'scroll', @debounceScroll
    )
    @state.set
      scrollTop: 0

  onScroll: (e) =>
    @state.set scrollTop: e.target.scrollTop

  canContinue: =>
    {addedItems} = @state.getValue()
    not _isEmpty(addedItems)

  render: =>
    {me, addedItems, addedItemsWithComponents, type, selectedPage,
      isFilterDialogVisible, isUnlimited, scrollTop,
      checkedItemGameKeyFilter, groupIds, toUserItems} = @state.getValue()

    windowHeight = window?.innerHeight or 480

    z '.z-new-trade-pick-items',
      z '.top',
        z '.g-grid',
          z '.title',
            if type is 'send'
            then @model.l.get 'newTradePickItems.offering'
            else @model.l.get 'newTradePickItems.want'
          z '.added-items',
            _map addedItemsWithComponents, ({itemInfo, $el}, i) =>
              z '.item', {
                onclick: =>
                  @addedItemsSteams.next \
                    RxObservable.of \
                      ItemService.removeItem addedItems, itemInfo
              },
                z $el, {
                  info: itemInfo
                  defaultLocked: isUnlimited
                  countOverlay: itemInfo.count
                  width: ADDED_CARD_WIDTH
                  onclick: -> null
                }

      z '.items-container', {
        style:
          # for chrome <= 30 / android < 4.4
          maxHeight: "#{windowHeight - TOP_HEIGHT_PX}px"
      },
        z '.g-grid',
          if toUserItems or type is 'receive'
            z '.tabs-wrapper',
              z @$tapTabs, {
                items: [
                  {
                    page: 'unfiltered'
                    name: if type is 'receive' and toUserItems \
                          then @model.l.get 'newTradePickItems.theirCollection'
                          else if type is 'receive'
                          then @model.l.get 'newTradePickItems.allItems'
                          else @model.l.get 'newTradePickItems.myCollection'
                  }
                  {
                    page: 'filtered'
                    name: if type is 'receive' \
                          then @model.l.get 'newTradePickItems.iNeed'
                          else @model.l.get 'newTradePickItems.theyNeed'
                  }
                ]
              }
          z '.search-filter',
            z '.search',
              z @$searchInput, {height: '36px'}
            # z '.filter',
            #   z @$filterButton,
            #     text:
            #       z @$filterIcon,
            #         icon: 'filter'
            #         color: colors.$secondary500
            #         isTouchTarget: false
            #     onclick: =>
            #       @state.set isFilterDialogVisible: true
          z @$itemList,
            scrollTop: scrollTop
            showCounts: not isUnlimited
            onclick: (clickedItem) =>
              @addedItemsSteams.next \
                RxObservable.of \
                  ItemService.addItem addedItems, clickedItem

      if isFilterDialogVisible
        z @$filterDialog,
          $content:
            z '.z-trade-pick-items_filter-dialog',
              z '.title', @model.l.get 'newTradePickItems.filter'
              z '.types',
                _map groupIds, (groupId) =>
                  z 'label.type',
                    z 'input.radio',
                      type: 'radio'
                      name: 'filter'
                      checked: checkedItemGameKeyFilter is groupId
                      onchange: =>
                        @state.set checkedItemGameKeyFilter: groupId
                    z '.label', _startCase groupId
              z '.actions',
                z @$cancelFilterButton,
                  text: @model.l.get 'general.cancel'
                  onclick: =>
                    @state.set isFilterDialogVisible: false
                  colors:
                    ink: colors.$flatButtonInk
                z @$setFilterButton,
                  text: @model.l.get 'general.ok'
                  onclick: =>
                    @groupIdFilter.next checkedItemGameKeyFilter
                    @state.set isFilterDialogVisible: false
                  colors:
                    ink: colors.$flatButtonInk
