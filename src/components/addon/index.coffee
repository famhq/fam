z = require 'zorium'

ShopOffers = require '../shop_offers'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class Addon
  constructor: ({@model, @router, addon, @isDonateDialogVisible}) ->
    player = @model.user.getMe().flatMapLatest ({id}) =>
      @model.player.getByUserIdAndGameId id, config.CLASH_ROYALE_ID
      .map (player) ->
        return player or {}

    @$shopOffers = new ShopOffers {@model, @router, player}

    @state = z.state
      addon: addon

  render: =>
    {addon} = @state.getValue()

    lang = @model.addon.getLang addon

    z '.z-addon',
      if addon?.id is 'f537f4b0-08cb-453c-8122-ae80e4163226'
        z @$shopOffers
      else
        z 'iframe.iframe',
          src: lang?.url
