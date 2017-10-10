z = require 'zorium'
_map = require 'lodash/map'
_take = require 'lodash/take'
_startCase = require 'lodash/startCase'
_snakeCase = require 'lodash/snakeCase'
_upperFirst = require 'lodash/upperFirst'
_camelCase = require 'lodash/camelCase'
_filter = require 'lodash/filter'
_find = require 'lodash/find'
Rx = require 'rx-lite'
Environment = require 'clay-environment'
moment = require 'moment'

Icon = require '../icon'
UiCard = require '../ui_card'
Dialog = require '../dialog'
RequestNotificationsCard = require '../request_notifications_card'
ClanBadge = require '../clan_badge'
PrimaryButton = require '../primary_button'
SecondaryButton = require '../secondary_button'
VerifyAccountDialog = require '../verify_account_dialog'
AdsenseAd = require '../adsense_ad'
FormatService = require '../../services/format'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ProfileInfo
  constructor: ({@model, @router, user, player, @overlay$}) ->
    @$trophyIcon = new Icon()
    @$arenaIcon = new Icon()
    @$levelIcon = new Icon()
    @$refreshIcon = new Icon()
    @$splitsInfoCard = new UiCard()
    @$followButton = new PrimaryButton()
    @$moreDetailsButton = new SecondaryButton()
    @$shopOffersButton = new SecondaryButton()
    @$verifyAccountButton = new SecondaryButton()
    @$clanBadge = new ClanBadge()
    @$dialog = new Dialog()
    @$verifyAccountDialog = new VerifyAccountDialog {@model, @router, @overlay$}
    @$adsenseAd = new AdsenseAd()

    isRequestNotificationCardVisible = new Rx.BehaviorSubject(
      window? and not Environment.isGameApp(config.GAME_KEY) and
        not localStorage?['hideNotificationCard']
    )
    @$requestNotificationsCard = new RequestNotificationsCard {
      @model
      isVisible: isRequestNotificationCardVisible
    }

    @state = z.state {
      isRequestNotificationCardVisible
      hasUpdatedPlayer: false
      isRefreshing: false
      isAutoRefresh: player.flatMapLatest (player) =>
        @model.player.getIsAutoRefreshByPlayerIdAndGameId(
          player.id, config.CLASH_ROYALE_ID
        )
      isSplitsInfoCardVisible: window? and not localStorage?['hideSplitsInfo']
      user: user
      me: @model.user.getMe()
      followingIds: @model.userFollower.getAllFollowingIds()
      player: player
    }

  beforeUnmount: =>
    @state.set isRefreshing: false, hasUpdatedPlayer: false

  getWinRateFromStats: (stats) ->
    winsAndLosses = stats?.wins + stats?.losses
    winRate = FormatService.percentage(
      if winsAndLosses and not isNaN winsAndLosses
      then stats?.wins / winsAndLosses
      else 0
    )

  getTypeStats: (stats) =>
    [
      {
        name: @model.l.get 'profileInfo.statWins'
        value: FormatService.number stats?.wins
      }
      {
        name: @model.l.get 'profileInfo.statLosses'
        value: FormatService.number stats?.losses
      }
      {
        name: @model.l.get 'profileInfo.statDraws'
        value: FormatService.number stats?.draws
      }
      {
        name: @model.l.get 'profileInfo.statWinRate'
        value: @getWinRateFromStats stats
      }
      {
        name: @model.l.get 'profileInfo.statCrownsEarned'
        value: FormatService.number stats?.crownsEarned
      }
      {
        name: @model.l.get 'profileInfo.statCrownsLost'
        value: FormatService.number stats?.crownsLost
      }
      # {
      #   name: @model.l.get 'profileInfo.statCurrentWinStreak'
      #   value: FormatService.number stats?.currentWinStreak
      # }
      # {
      #   name: @model.l.get 'profileInfo.statCurrentLossStreak'
      #   value: FormatService.number stats?.currentLossStreak
      # }
      # {
      #   name: @model.l.get 'profileInfo.statMaxWinStreak'
      #   value: FormatService.number stats?.maxWinStreak
      # }
      # {
      #   name: @model.l.get 'profileInfo.statMaxLossStreak'
      #   value: FormatService.number stats?.maxLossStreak
      # }
    ]

  render: =>
    {player, isRequestNotificationCardVisible, hasUpdatedPlayer, isRefreshing,
      isAutoRefresh, isSplitsInfoCardVisible, user, me,
      followingIds} = @state.getValue()

    isMe = user?.id and user?.id is me?.id
    isFollowing = followingIds and followingIds.indexOf(user?.id) isnt -1

    metrics =
      stats: [
        {
          name: @model.l.get 'profileInfo.statWins'
          value: FormatService.number(
            player?.data?.wins
          )
        }
        {
          name: @model.l.get 'profileInfo.statLosses'
          value: FormatService.number(
            player?.data?.losses
          )
        }
        {
          name: @model.l.get 'profileInfo.statWinRate'
          value: @getWinRateFromStats player?.data?.stats
        }
        {
          name: @model.l.get 'profileInfo.statFavoriteCard'
          value: @model.clashRoyaleCard.getNameTranslation(
            player?.data?.currentFavouriteCard?.name or
            player?.data?.stats?.favoriteCard # legacy
          )
        }
        {
          name: @model.l.get 'profileInfo.statThreeCrowns'
          value: FormatService.number(
            player?.data?.threeCrownWins or
            player?.data?.stats?.threeCrowns # legacy
          )
        }
        {
          name: @model.l.get 'profileInfo.statCardsFound'
          value: FormatService.number(
            player?.data?.cards?.length or
            player?.data?.stats?.cardsFound # legacy
          )
        }
        {
          name: @model.l.get 'profileInfo.statMaxTrophies'
          value: FormatService.number(
            player?.data?.bestTrophies or
            player?.data?.stats?.maxTrophies # legacy
          )
        }
        {
          name: @model.l.get 'profileInfo.statTotalDonations'
          value: FormatService.number(
            player?.data?.totalDonations or
            player?.data?.stats?.totalDonations # legacy
          )
        }
      ]
      ladder: @getTypeStats _find player?.counters, {gameType: 'PvP'}
      grandChallenge: @getTypeStats _find player?.counters, {
        gameType: 'grandChallenge'
      }
      classicChallenge: @getTypeStats _find player?.counters, {
        gameType: 'classicChallenge'
      }
      '2v2': @getTypeStats _find player?.counters, {gameType: '2v2'}

    lastUpdateTime = player?.lastUpdateTime

    canRefresh = @model.player.canRefresh player, hasUpdatedPlayer, isRefreshing

    z '.z-profile-info',
      z '.header',
        z '.g-grid',
          z '.info',
            z '.left',
              z '.name', player?.data?.name
              z '.tag', "##{player?.id}"
            if player?.data?.clan
              z '.right',
                z '.clan-info',
                  z '.clan-name', player?.data?.clan.name
                  z '.clan-tag', "#{player?.data?.clan.tag}"
                z '.clan-badge',
                  z @$clanBadge, {clan: player?.data?.clan, size: '32px'}
          z '.g-cols',
            z '.g-col.g-xs-4',
              z '.icon',
                z @$trophyIcon,
                  icon: 'trophy'
                  color: colors.$secondary500
              z '.text', player?.data?.trophies
            z '.g-col.g-xs-4',
              z '.icon',
                z @$arenaIcon,
                  icon: 'castle'
                  color: colors.$secondary500
              z '.text',
                if player?.data?.arena?.name
                  player?.data?.arena?.name
                else
                  [
                    @model.l.get 'general.arena'
                    " #{player?.data?.arena?.number}"
                  ]
              # if player?.data?.league
              #   z '.text', player?.data?.league?.name
            z '.g-col.g-xs-4',
              z '.icon',
                z @$levelIcon,
                  icon: 'crown'
                  color: colors.$secondary500
              z '.text',
                @model.l.get 'general.level'
                " #{player?.data?.expLevel or player?.data?.level}"
        z '.divider'
        z '.g-grid',
          z '.last-updated',
            z '.time',
              @model.l.get 'profileInfo.lastUpdatedTime'
              ' '
              moment(lastUpdateTime).fromNowModified()
            z '.auto-refresh',
              @model.l.get 'profileInfo.autoRefresh'
              z 'span.status',
                if isAutoRefresh
                  @model.l.get 'general.on'
                else
                  z 'span', {
                    onclick: =>
                      @overlay$.onNext @$verifyAccountDialog
                  },
                    @model.l.get 'general.off'
            z '.refresh',
              z @$refreshIcon,
                icon: if isRefreshing then 'ellipsis' else 'refresh'
                isTouchTarget: false
                color: if canRefresh \
                       then colors.$primary500
                       else colors.$tertiary300
                onclick: =>
                  if isRefreshing
                    return
                  if canRefresh
                    tag = player?.id
                    @state.set isRefreshing: true
                    # re-rendering with new state isn't instantaneous, this is
                    canRefresh = false
                    @model.clashRoyaleAPI.refreshByPlayerId tag
                    .then =>
                      @state.set hasUpdatedPlayer: true, isRefreshing: false
                  else
                    @overlay$.onNext z @$dialog, {
                      isVanilla: true
                      $title: @model.l.get 'profileInfo.waitTitle'
                      $content: @model.l.get 'profileInfo.waitDescription', {
                        replacements:
                          number: '10'
                      }
                      onLeave: =>
                        @overlay$.onNext null
                      submitButton:
                        text: @model.l.get 'installOverlay.closeButtonText'
                        onclick: =>
                          @overlay$.onNext null
                    }

          if isMe and player and not player?.isVerified
            z '.verify-button',
              z @$verifyAccountButton,
                text: @model.l.get 'clanInfo.verifySelf'
                onclick: =>
                  @overlay$.onNext @$verifyAccountDialog
          else if not isMe
            z '.follow-button',
              z @$followButton,
                text: if isFollowing \
                    then @model.l.get 'profileInfo.followButtonIsFollowingText'
                    else @model.l.get 'profileInfo.followButtonText'
                onclick: =>
                  if isFollowing
                    @model.userFollower.unfollowByUserId user?.id
                  else
                    @model.userFollower.followByUserId user?.id
      z '.content',
        if isRequestNotificationCardVisible and isMe
          z '.card',
            z '.g-grid',
              z @$requestNotificationsCard

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

        if player?.data?.upcomingChests
          upcomingChests = _filter player?.data.upcomingChests.items, (item) ->
            item.index? and item.index < 8
          z '.block',
            z '.g-grid',
              z '.title', @model.l.get 'profileChests.chestsTitle'
              z '.chests', {
                ontouchstart: (e) ->
                  e?.stopPropagation()
              },
                _map upcomingChests, ({name, index}, i) ->
                  chest = _snakeCase name
                  z 'img.chest',
                    src: "#{config.CDN_URL}/chests/#{chest}.png"
                    width: 90
                    height: 90
              z '.chests-button',
                z 'div',
                  z @$moreDetailsButton,
                    text: @model.l.get 'profileInfo.moreDetailsButtonText'
                    onclick: =>
                      @router.go "/user/id/#{user?.id}/chests"
        # legacy
        else if player?.data?.chestCycle
          z '.block',
            z '.g-grid',
              z '.title', @model.l.get 'profileChests.chestsTitle'
              z '.chests', {
                ontouchstart: (e) ->
                  e?.stopPropagation()
              },
                _map _take(player?.data.chestCycle.chests, 10), (chest, i) ->
                  if i is player?.data.chestCycle.countUntil.superMagical
                    chest = 'super_magical'
                  else if i is player?.data.chestCycle.countUntil.legendary
                    chest = 'legendary'
                  else if i is player?.data.chestCycle.countUntil.epic
                    chest = 'epic'
                  z 'img.chest',
                    src: "#{config.CDN_URL}/chests/#{chest}_chest.png"
                    width: 90
                    height: 90
              z '.chests-button',
                z 'div',
                  z @$moreDetailsButton,
                    text: @model.l.get 'profileInfo.moreDetailsButtonText'
                    onclick: =>
                      @router.go "/user/id/#{user?.id}/chests"
                z 'div',
                  z @$shopOffersButton,
                    text: @model.l.get 'profileChests.viewShopOffers'
                    onclick: =>
                      @router.go '/addon/clash-royale/shop-offers'


        z '.block',
          _map metrics, (stats, key) =>
            z '.g-grid',
              if key is 'ladder' and isSplitsInfoCardVisible
                z '.splits-info-card',
                  z @$splitsInfoCard,
                    text: @model.l.get 'profileInfo.splitsInfoCardText'
                    submit:
                      text: @model.l.get 'installOverlay.closeButtonText'
                      onclick: =>
                        @state.set isSplitsInfoCardVisible: false
                        localStorage?['hideSplitsInfo'] = '1'
              z '.title',
                @model.l.get 'profileInfo.subhead' + _upperFirst _camelCase key
              z '.g-cols',
                _map stats, ({name, value}) ->
                  z '.g-col.g-xs-6',
                    z '.name', name
                    z '.value', value
