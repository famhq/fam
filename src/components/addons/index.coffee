z = require 'zorium'
_isEmpty = require 'lodash/isEmpty'
_map = require 'lodash/map'

Spinner = require '../spinner'
AddonListItem = require '../addon_list_item'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class Addons
  constructor: ({@model, @router, gameKey, sort, filter}) ->
    @$spinner = new Spinner()

    me = @model.user.getMe()
    addons = @model.addon.getAll({sort, filter})
    # streams = @model.stream.getAll({sort, filter})

    @state = z.state
      me: @model.user.getMe()
      gameKey: gameKey
      $addons: addons.map (addons) =>
        _map addons, (addon) =>
          new AddonListItem {@model, @router, gameKey, addon}

  render: =>
    {me, $addons, gameKey} = @state.getValue()

    z '.z-addons',
      z 'h2.title', @model.l.get 'addons.discover'
      z '.addons',
        if $addons and _isEmpty $addons
          'No addons found'
        else if $addons
          _map $addons, ($addon) ->
            z '.addon', $addon

        else
          @$spinner
