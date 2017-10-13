z = require 'zorium'

ShopOffers = require '../shop_offers'
TopTouchdownCards = require '../top_touchdown_cards'
ChestSimulatorPick = require '../simulator_pick'
ForumSignature = require '../forum_signature'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class Addon
  constructor: ({@model, @router, addon, testUrl}) ->
    player = @model.user.getMe().switchMap ({id}) =>
      @model.player.getByUserIdAndGameId id, config.CLASH_ROYALE_ID
      .map (player) ->
        return player or {}

    @$shopOffers = new ShopOffers {@model, @router, player}
    @$chestSimulatorPick = new ChestSimulatorPick {@model, @router}
    @$topTouchdownCards = new TopTouchdownCards {@model, @router}
    @$forumSignature = new ForumSignature {@model, @router}

    @state = z.state
      addon: addon
      testUrl: testUrl
      windowSize: @model.window.getSize()
      appBarHeight: @model.window.getAppBarHeight()

  render: =>
    {addon, testUrl, windowSize, appBarHeight} = @state.getValue()

    z '.z-addon',
      if addon?.id is 'f537f4b0-08cb-453c-8122-ae80e4163226'
        z @$shopOffers
      else if addon?.id is 'c22ef0b0-f4fb-4e9d-b065-28991390cec8'
        @$topTouchdownCards
      else if addon?.id is '8787842f-bc03-4070-a541-39062be97fdc'
        z @$chestSimulatorPick
      else if addon?.id is 'db0593b5-114f-43db-9d98-0b0a88ce3d12'
        z @$forumSignature
      else
        z 'iframe.iframe',
          src: testUrl or addon?.url.replace '{lang}', @model.l.getLanguageStr()
          style:
            height: "#{windowSize.height - appBarHeight}px"
