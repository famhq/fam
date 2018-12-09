z = require 'zorium'
Environment = require '../../services/environment'
_map = require 'lodash/map'
_snakeCase = require 'lodash/snakeCase'

AdsenseAd = require '../adsense_ad'
Simulator = require '../simulator'
Spinner = require '../spinner'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ChestSimulatorPick
  constructor: ({@model}) ->
    @$adsenseAd = new AdsenseAd {@model}
    @$spinner = new Spinner()

    @state = z.state
      $simulator: null
      loadingChest: null

  openChest: (chest) =>
    localStorage?['chestsOpened'] ?= 0
    newChestsOpened = parseInt(localStorage?['chestsOpened']) + 1
    localStorage?['chestsOpened'] = newChestsOpened

    showAdAfter = Environment.isNativeApp(config.GAME_KEY) and
                    not (newChestsOpened % 5)

    ga? 'send', 'event', 'simulator', 'open', chest

    if showAdAfter
      @model.portal.call 'admob.prepareInterstitial', {
        adId: if Environment.isiOS() \
              then 'ca-app-pub-9043203456638369/4505810435'
              else 'ca-app-pub-9043203456638369/8759560843'
      }

    @state.set loadingChest: chest
    @model.clashRoyaleCard.getChestCards {
      chest, arena: 'arena11'
    }
    .then (cards) =>
      @state.set loadingChest: null, $simulator: new Simulator {
        @model, chest, cards, showAdAfter
        onClose: =>
          if showAdAfter
            @model.portal.call 'admob.showInterstitial'
          @state.set $simulator: null
      }

  render: =>
    {$simulator, loadingChest} = @state.getValue()

    chests = [
      'superMagical', 'legendary', 'magical', 'epic', 'giant', 'megaLightning'
      'gold', 'silver'
    ]

    z '.z-simulator-pick',
      if $simulator
        z $simulator
      else
        [
          z '.g-grid.chests',
            z '.g-cols',
              _map chests, (chest) =>
                z '.g-col.g-xs-4.g-md-3',
                  if loadingChest is chest
                    z '.chest',
                      @$spinner
                  else
                    z '.chest', {
                      style:
                        backgroundImage:
                          "url(#{config.CDN_URL}/chests/#{_snakeCase(chest)}_chest.png)"
                      onclick: => @openChest chest
                    }
          if Environment.isMobile() and not Environment.isNativeApp(config.GAME_KEY)
            z '.ad',
              z @$adsenseAd, {
                slot: 'mobile300x250'
              }
          else if not Environment.isMobile()
            z '.ad',
              z @$adsenseAd, {
                slot: 'desktop728x90'
              }
        ]
