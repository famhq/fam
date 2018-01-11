z = require 'zorium'
_map = require 'lodash/map'
_uniqBy = require 'lodash/uniqBy'
RxObservable = require('rxjs/Observable').Observable
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
require 'rxjs/add/observable/combineLatest'

ItemList = require '../item_list'
StickerInfo = require '../sticker_info'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class Collection
  constructor: ({@model, @router, gameKey, group, @overlay$}) ->
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

    @$itemList = new ItemList {@model, @router, items, userItems}

    @clickedInfo = new RxReplaySubject 1
    @$stickerInfo = new StickerInfo {
      @model
      @router
      infoStreams: @clickedInfo
      onClose: =>
        @overlay$.next null
    }

    @state = z.state
      me: @model.user.getMe()
      gameKey: gameKey

  render: =>
    {me, gameKey} = @state.getValue()

    z '.z-collection',
      z '.g-grid',
        z @$itemList, {
          onclick: (itemInfo) =>
            @clickedInfo.next RxObservable.of itemInfo
            @overlay$.next @$stickerInfo
        }
