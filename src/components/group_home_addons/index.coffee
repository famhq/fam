z = require 'zorium'
_map = require 'lodash/map'
_filter = require 'lodash/filter'

Base = require '../base'
Spinner = require '../spinner'
AddonListItem = require '../addon_list_item'
UiCard = require '../ui_card'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class GroupHomeAddons extends Base
  constructor: ({@model, @router, group, player, @overlay$}) ->
    me = @model.user.getMe()

    @$spinner = new Spinner()
    @$uiCard = new UiCard()

    addons = group.switchMap (group) =>
      @model.addon.getAllByGroupId group.id

    @state = z.state {
      group
      $addons: addons.map (addons) =>
        addons = _filter addons, (addon) ->
          addon.key in [
            'chestSimulator', 'clanManager', 'deckBandit', 'stormShieldOne'
          ]
        _map addons, (addon) =>
          new AddonListItem {@model, @router, addon}
    }

  beforeUnmount: ->
    super()

  render: =>
    {group, $addons} = @state.getValue()

    z '.z-group-home-addons',
      z @$uiCard,
        $title: @model.l.get 'groupHome.popularAddons'
        $content:
          z '.z-group-home_ui-card',
            _map $addons, ($addon) ->
              z '.list-item',
                z $addon, {hasPadding: false}
        submit:
          text: @model.l.get 'general.viewAll'
          onclick: =>
            @router.go 'groupTools', {groupId: group.key or group.id}
