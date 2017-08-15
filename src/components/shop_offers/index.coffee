z = require 'zorium'
_map = require 'lodash/map'
_sortBy = require 'lodash/sortBy'
Rx = require 'rx-lite'
Environment = require 'clay-environment'
moment = require 'moment'

AdsenseAd = require '../adsense_ad'
Icon = require '../icon'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ShopOffers
  constructor: ({@model, @router, player}) ->
    @$adsenseAd = new AdsenseAd()
    @$refreshIcon = new Icon()

    @state = z.state {
      me: @model.user.getMe()
      player: player
      hasUpdatedPlayer: false
      isRefreshing: false
    }

  render: =>
    {player, me, hasUpdatedPlayer, isRefreshing} = @state.getValue()

    shopOffers = _map player?.data?.shopOffers, (days, chest) ->
      {days, chest}
    shopOffers = _sortBy shopOffers, 'days'
    lastUpdateTime = if player?.lastDataUpdateTime > player?.lastMatchesUpdateTime \
                     then player?.lastDataUpdateTime
                     else player?.lastMatchesUpdateTime

    z '.z-shop-offers',
      z '.g-grid',
        z '.title', @model.l.get 'profileChests.daysUntilTitle'
        z '.chests-until',
          _map shopOffers, ({days, chest}) =>
            if days >= 0
              if chest is 'arena'
                arena = player.data.arena?.number
                imageUrl = "#{config.CDN_URL}/arenas/#{arena}.png"
              else
                imageUrl = "#{config.CDN_URL}/chests/#{chest}_opened.png?1"
              z '.chest',
                z '.image',
                  style:
                    backgroundImage:
                      "url(#{imageUrl})"
                z '.info',
                  z '.name', @model.l.get("crChest.#{chest}Offer")
                  z '.count',
                    "#{days} #{@model.l.get 'general.days'}"

        z '.last-updated',
          z '.time',
            @model.l.get 'profileInfo.lastUpdatedTime'
            ' '
            moment(lastUpdateTime).fromNowModified()
          console.log player, hasUpdatedPlayer
          if player?.isUpdatable and not hasUpdatedPlayer
            console.log '1'
            z '.refresh',
              if isRefreshing
                '...'
              else
                console.log '2'
                z @$refreshIcon,
                  icon: 'refresh'
                  isTouchTarget: false
                  color: colors.$primary500
                  onclick: =>
                    tag = player?.id
                    @state.set isRefreshing: true
                    @model.clashRoyaleAPI.refreshByPlayerId tag
                    .then =>
                      @state.set hasUpdatedPlayer: true, isRefreshing: false


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
