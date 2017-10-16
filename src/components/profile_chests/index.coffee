z = require 'zorium'
_map = require 'lodash/map'
_find = require 'lodash/find'
_chunk = require 'lodash/chunk'
_filter = require 'lodash/filter'
_startCase = require 'lodash/startCase'
_camelCase = require 'lodash/camelCase'
_snakeCase = require 'lodash/snakeCase'
_sortBy = require 'lodash/sortBy'
Rx = require 'rxjs'
Environment = require 'clay-environment'

AdsenseAd = require '../adsense_ad'
PrimaryButton = require '../primary_button'
SecondaryButton = require '../secondary_button'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ProfileChests
  constructor: ({@model, @router, player}) ->
    @$adsenseAd = new AdsenseAd()
    @$shareButton = new PrimaryButton()
    @$shopOffersButton = new SecondaryButton()

    @state = z.state {
      me: @model.user.getMe()
      player: player
    }

  render: =>
    {player, me} = @state.getValue()

    isNative = Environment.isGameApp config.GAME_KEY
    isVerified = player?.isVerified

    goodChests = ['giant', 'epic', 'magical', 'superMagical', 'legendary']

    z '.z-profile-chests',
      z '.g-grid',
        z '.title', @model.l.get 'profileChests.chestsTitle'
        z '.chests', {
          ontouchstart: (e) ->
            e?.stopPropagation()
        },
          if player?.data.upcomingChests
            upcomingChests = _filter player?.data.upcomingChests.items, (item) ->
              item.index? and item.index < 8
            _map upcomingChests, ({name, index}) =>
              chest = _snakeCase name
              z '.chest',
                z 'img',
                  src: "#{config.CDN_URL}/chests/#{chest}.png"
                  width: 90
                  height: 90
                z '.count',
                  if index is 0
                  then @model.l.get('general.next')
                  else "+#{index}"
          else if player?.data.chestCycle # LEGACY TODO: rm after mid sept
            _map player?.data.chestCycle.chests, (chest, i) =>
              if i is player?.data.chestCycle.countUntil.superMagical
                chest = 'super_magical'
              else if i is player?.data.chestCycle.countUntil.legendary
                chest = 'legendary'
              else if i is player?.data.chestCycle.countUntil.epic
                chest = 'epic'
              z '.chest',
                z 'img',
                  src: "#{config.CDN_URL}/chests/#{chest}_chest.png"
                  width: 90
                  height: 90
                z '.count',
                  if i is 0 then @model.l.get('general.next') else "+#{i + 1}"


        if Environment.isMobile() and not Environment.isGameApp(config.GAME_KEY)
          z '.ad',
            z @$adsenseAd, {
              slot: 'mobile300x250'
            }
        else if not Environment.isMobile()
          z '.ad',
            z @$adsenseAd, {
              slot: 'desktop728x90'
            }

        z '.title', @model.l.get 'profileChests.chestsUntilTitle'
        z '.chests-until',
          _map _chunk(goodChests, 3), (chunk) =>
            z '.row',
              _map chunk, (chest) =>
                if player?.data.upcomingChests
                  index = _find(player?.data.upcomingChests.items, ({name}) ->
                    _camelCase(name) is "#{chest}Chest"
                  )?.index
                else if player?.data.chestCycle?.countUntil # legacy
                  index = player?.data.chestCycle.countUntil[chest]
                if index?
                  z '.chest',
                    z '.image',
                      style:
                        backgroundImage:
                          "url(#{config.CDN_URL}/chests/" +
                          "#{_snakeCase(chest)}_chest.png)"
                    z '.info',
                      z '.name', @model.l.get "crChest.#{chest}"
                      z '.count',
                        "+#{index}"


        z @$shareButton,
          text: @model.l.get 'general.share'
          onclick: =>
            @model.portal.call 'share.any', {
              text: ''
              image: "#{config.PUBLIC_API_URL}/di/crChestCycle/#{me?.id}.png"
              path: if me?.username \
                    then "/user/#{me.username}/chests"
                    else "/user/id/#{me?.id}/chests"
            }
