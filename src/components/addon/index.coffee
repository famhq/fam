z = require 'zorium'

ShopOffers = require '../shop_offers'
ChestSimulatorPick = require '../simulator_pick'
ForumSignature = require '../forum_signature'
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
    @$chestSimulatorPick = new ChestSimulatorPick {@model, @router}
    @$forumSignature = new ForumSignature {@model, @router}

    @state = z.state
      addon: addon

  render: =>
    {addon} = @state.getValue()

    z '.z-addon',
      if addon?.id is 'f537f4b0-08cb-453c-8122-ae80e4163226'
        z @$shopOffers
      else if addon?.id is '8787842f-bc03-4070-a541-39062be97fdc'
        z @$chestSimulatorPick
      else if addon?.id is 'db0593b5-114f-43db-9d98-0b0a88ce3d12'
        z @$forumSignature
      else
        z 'iframe.iframe',
          src: addon?.url.replace '{lang}', @model.l.getLanguageStr()
