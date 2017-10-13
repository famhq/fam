z = require 'zorium'
_map = require 'lodash/map'
_sortBy = require 'lodash/sortBy'
Rx = require 'rxjs'
Environment = require 'clay-environment'
moment = require 'moment'

AdsenseAd = require '../adsense_ad'
GetPlayerTagForm = require '../get_player_tag_form'
Icon = require '../icon'
Spinner = require '../spinner'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ShopOffers
  constructor: ({@model, @router, player}) ->
    @$adsenseAd = new AdsenseAd()
    @$refreshIcon = new Icon()
    @$spinner = new Spinner()
    @$getPlayerTagForm = new GetPlayerTagForm {@model, @router}

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
    lastUpdateTime = player?.lastUpdateTime

    z '.z-shop-offers',
      @model.l.get 'shopOffers.rip'
      # if not player
      #   z @$spinner
      # else if not player?.id
      #   z '.g-grid',
      #     z '.link', @model.l.get 'newThread.link'
      #     @$getPlayerTagForm
      # else
      #   z '.g-grid',
      #     z '.title', @model.l.get 'profileChests.daysUntilTitle'
      #     z '.chests-until',
      #       _map shopOffers, ({days, chest}) =>
      #         if days >= 0
      #           if chest is 'arena'
      #             arena = player.data.arena?.number
      #             imageUrl = "#{config.CDN_URL}/arenas/#{arena}.png"
      #           else
      #             imageUrl = "#{config.CDN_URL}/chests/#{chest}_opened.png?1"
      #           z '.chest',
      #             z '.image',
      #               style:
      #                 backgroundImage:
      #                   "url(#{imageUrl})"
      #             z '.info',
      #               z '.name', @model.l.get("crChest.#{chest}Offer")
      #               z '.count',
      #                 "#{days} #{@model.l.get 'general.days'}"
      #
      #     z '.last-updated',
      #       z '.time',
      #         @model.l.get 'profileInfo.lastUpdatedTime'
      #         ' '
      #         moment(lastUpdateTime).fromNowModified()
      #       if @model.player.canRefresh player
      #         z '.refresh',
      #           if isRefreshing
      #             '...'
      #           else
      #             z @$refreshIcon,
      #               icon: 'refresh'
      #               isTouchTarget: false
      #               color: colors.$primary500
      #               onclick: =>
      #                 tag = player?.id
      #                 @state.set isRefreshing: true
      #                 @model.clashRoyaleAPI.refreshByPlayerId tag, {
      #                   isLegacy: true
      #                 }
      #                 .then =>
      #                   @state.set hasUpdatedPlayer: true, isRefreshing: false


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
