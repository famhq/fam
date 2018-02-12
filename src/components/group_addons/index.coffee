z = require 'zorium'
_isEmpty = require 'lodash/isEmpty'
_map = require 'lodash/map'

Spinner = require '../spinner'
AddonListItem = require '../addon_list_item'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class GroupAddons
  constructor: ({@model, @router, group}) ->
    @$spinner = new Spinner()

    me = @model.user.getMe()
    addons = group.switchMap (group) =>
      @model.addon.getAllByGroupId group.id
    # streams = @model.stream.getAll({sort, filter})

    @state = z.state
      me: @model.user.getMe()
      $addons: addons.map (addons) =>
        _map addons, (addon) =>
          new AddonListItem {@model, @router, addon}

  render: =>
    {me, $addons} = @state.getValue()

    z '.z-addons',
      z '.g-grid',
        z 'h2.title', @model.l.get 'addons.discover'
        z '.g-cols.addons',
          if $addons and _isEmpty $addons
            'No addons found'
          else if $addons
            _map $addons, ($addon) ->
              z '.g-col.g-sm-12.g-md-6.addon', $addon

          else
            @$spinner
