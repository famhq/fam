z = require 'zorium'
_isEmpty = require 'lodash/isEmpty'
_defaults = require 'lodash/defaults'
_reduce = require 'lodash/reduce'

TopTouchdownCards = require '../top_touchdown_cards'
TopDraftCards = require '../top_draft_cards'
TopChallengeDecks = require '../top_challenge_decks'
Top2v2Decks = require '../top_2v2_decks'
FortniteWeapons = require '../fortnite_weapons'
NewCards = require '../new_cards'
ChestSimulatorPick = require '../simulator_pick'
Clan = require '../clan'
Players = require '../clash_royale_players'
Recruiting = require '../clash_royale_recruiting'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class Addon
  constructor: ({@model, @router, addon, testUrl, replacements, group}) ->
    player = @model.user.getMe().switchMap ({id}) =>
      (if playerId = replacements?.playerTag
      then @model.player.getByPlayerIdAndGameKey playerId, 'clash-royale'
      else @model.player.getByUserIdAndGameKey id, 'clash-royale')
      .map (player) ->
        return player or {}

    @$chestSimulatorPick = new ChestSimulatorPick {@model, @router}
    @$topTouchdownCards = new TopTouchdownCards {@model, @router}
    @$topChallengeDecks = new TopChallengeDecks {@model, @router}
    @$top2v2Decks = new Top2v2Decks {@model, @router}
    @$topDraftCards = new TopDraftCards {@model, @router}
    @$newCards = new NewCards {@model, @router}
    @$clan = new Clan {@model, @router, player}
    @$players = new Players {@model, @router}
    @$recruiting = new Recruiting {@model, @router, group}
    @$fortniteWeapons = new FortniteWeapons {@model, @router}

    @state = z.state
      addon: addon
      testUrl: testUrl
      replacements: replacements
      windowSize: @model.window.getSize()
      appBarHeight: @model.window.getAppBarHeight()

  render: =>
    {addon, testUrl, windowSize, appBarHeight, replacements} = @state.getValue()

    if _isEmpty(addon?.data?.translatedLanguages) or
          addon?.data?.translatedLanguages.indexOf(
            @model.l.getLanguageStr()
          ) isnt -1
      language = @model.l.getLanguageStr()
    else
      language = 'en'

    z '.z-addon', {
      style:
        # because safari tries to auto-expand iframes...
        height: "#{windowSize.height - appBarHeight}px"
        width: "#{windowSize.width}px"
    },
      if addon?.id is 'c22ef0b0-f4fb-4e9d-b065-28991390cec8'
        @$topTouchdownCards
      else if addon?.id is 'f6096723-be39-41c5-b2c8-ed44892595a3'
        z @$topDraftCards
      else if addon?.id is 'f3dae359-ce93-4039-a2cf-421c92e423cf'
        z @$newCards
      else if addon?.id is '8787842f-bc03-4070-a541-39062be97fdc'
        z @$chestSimulatorPick
      else if addon?.id is 'a8370ac8-d07e-454a-824d-bee1b5266ea4'
        z @$topChallengeDecks
      else if addon?.id is '7da4d705-6180-4ceb-869e-cb6f0f8e004d'
        z @$top2v2Decks
      else if addon?.id is '32758e1c-af5b-44b1-bfe5-7379ca8fdfa2'
        z @$clan
      else if addon?.id is 'fc71726d-d721-443e-b247-9d1439d09b60'
        z @$players
      else if addon?.id is '3278305f-1e2e-450f-8611-0fa290216753'
        z @$recruiting
      else if addon?.id is '842e07ae-407d-493c-a43c-bb5e755a3900'
        z @$fortniteWeapons
      else if testUrl or addon?.url
        replacements = _defaults replacements, {lang: language}
        vars = addon?.url?.match /\{[a-zA-Z0-9]+\}/g
        url = _reduce vars, (str, variable) ->
          key = variable.replace /\{|\}/g, ''
          str.replace variable, replacements[key] or ''
        , addon?.url
        z 'iframe.iframe',
          src: testUrl or url
          # because safari tries to auto-expand iframes...
          # height: "#{windowSize.height - appBarHeight}px"
          # width: "#{windowSize.width}px"
