z = require 'zorium'

FormatService = require '../../services/format'
colors = require '../../colors'

if window?
  require './index.styl'

Icon = require '../icon'
CurrencyIcon = require '../currency_icon'

module.exports = class MenuFireAmount
  constructor: ({@model, @router, group}) ->
    itemKey = group.map (group) ->
      group.currency?.itemKey

    @$fireIcon = new Icon()
    @$currencyIcon = new CurrencyIcon {
      itemKey: itemKey
    }

    @state = z.state
      me: @model.user.getMe()
      group: group
      currencyItem: itemKey.switchMap (itemKey) =>
        @model.userItem.getByItemKey itemKey

  render: =>
    {me, group, currencyItem} = @state.getValue()


    z '.z-menu-fire-amount', {
      onclick: =>
        @router.go 'groupFire', {groupId: group?.id}
    },
      z '.fire',
        FormatService.number me?.fire
        z '.icon',
          z @$fireIcon,
            icon: 'fire'
            color: colors.$quaternary500
            isTouchTarget: false
            size: '20px'
      if group?.currency
        z '.group-currency',
          FormatService.number currencyItem?.count or 0
          z '.icon',
            z @$currencyIcon, {size: '20px'}
