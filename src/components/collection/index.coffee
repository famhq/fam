z = require 'zorium'
_map = require 'lodash/map'
_uniqBy = require 'lodash/uniqBy'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/combineLatest'

ItemList = require '../item_list'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class Collection
  constructor: ({@model, @router, gameKey, @overlay$}) ->
    # TODO: group-specific?
    userItems = @model.userItem.getAll()
    allItems = @model.item.getAll()
    .map (items) ->
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

    @state = z.state
      me: @model.user.getMe()
      gameKey: gameKey

  render: =>
    {me, gameKey} = @state.getValue()

    z '.z-collection',
      @$itemList
