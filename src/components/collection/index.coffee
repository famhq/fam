z = require 'zorium'
_map = require 'lodash/map'
_uniqBy = require 'lodash/uniqBy'
RxObservable = require('rxjs/Observable').Observable
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
require 'rxjs/add/observable/combineLatest'

ItemList = require '../item_list'
StickerInfo = require '../sticker_info'
OpenChest = require '../open_chest'
UiCard = require '../ui_card'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class Collection
  constructor: ({@model, @router, group, @overlay$, @selectedIndex}) ->
    userItems = @model.userItem.getAll()
    allItems = group.switchMap ({id}) =>
      @model.item.getAllByGroupId id

    allItems = allItems.map (items) ->
      _map items, (item) ->
        {itemKey: item.key, count: 0, item}

    userItemsAndAllItems = RxObservable.combineLatest(
      userItems
      allItems
      (vals...) -> vals
    )

    items = userItemsAndAllItems.map ([userItems, allItems]) ->
      userItems ?= []
      _uniqBy userItems.concat(allItems), 'itemKey'

    @$itemList = new ItemList {
      @model, @router, items, userItems, group, showName: true
    }

    @clickedInfo = new RxReplaySubject 1
    @$stickerInfo = new StickerInfo {
      @model
      @router
      infoStreams: @clickedInfo
      onClose: =>
        @overlay$.next null
    }
    @$openChest = new OpenChest {
      @model
      @router
      infoStreams: @clickedInfo
      group: group
      @overlay$
    }
    @$infoCard = new UiCard()

    @state = z.state
      me: @model.user.getMe()
      group: group
      isInfoCardVisible: not @model.cookie.get 'isCollectionInfoCardVisible'

  render: =>
    {me, group, isInfoCardVisible} = @state.getValue()

    z '.z-collection',
      z '.g-grid',
        if isInfoCardVisible
          z '.info-card',
            z @$infoCard,
              $content: @model.l.get 'collection.infoCard'
              cancel:
                text: @model.l.get 'installOverlay.closeButtonText'
                onclick: =>
                  @state.set isInfoCardVisible: false
                  @model.cookie.set 'isCollectionInfoCardVisible', '1'
              submit:
                text: @model.l.get 'groupHome.goToShop'
                onclick: =>
                  @selectedIndex.next 1

        z @$itemList, {
          onclick: (itemInfo) =>
            @clickedInfo.next RxObservable.of itemInfo
            if itemInfo.item.type is 'chest'
              @overlay$.next @$openChest
            else if itemInfo.item.type is 'sticker'
              @overlay$.next @$stickerInfo
            else if itemInfo.item.type is 'consumable' and itemInfo.count > 0
              @model.userItem.consumeByItemKey itemInfo.item.key, {
                groupId: group.id
              }
        }
