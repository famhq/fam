z = require 'zorium'

ItemList = require '../item_list'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class Collection
  constructor: ({@model, @router, gameKey, @overlay$}) ->
    items = @model.userItem.getAll()

    @$itemList = new ItemList {@model, @router, items, userItems: items}

    @state = z.state
      me: @model.user.getMe()
      gameKey: gameKey

  render: =>
    {me, gameKey} = @state.getValue()

    z '.z-collection',
      @$itemList
