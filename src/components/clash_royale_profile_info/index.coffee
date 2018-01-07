z = require 'zorium'
_map = require 'lodash/map'
_take = require 'lodash/take'
_startCase = require 'lodash/startCase'
_snakeCase = require 'lodash/snakeCase'
_upperFirst = require 'lodash/upperFirst'
_camelCase = require 'lodash/camelCase'
_filter = require 'lodash/filter'
_find = require 'lodash/find'
Environment = require 'clay-environment'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
require 'rxjs/add/operator/switchMap'

Icon = require '../icon'
UiCard = require '../ui_card'
Dialog = require '../dialog'
RequestNotificationsCard = require '../request_notifications_card'
ClanBadge = require '../clan_badge'
PrimaryButton = require '../primary_button'
SecondaryButton = require '../secondary_button'
AddonListItem = require '../addon_list_item'
VerifyAccountDialog = require '../verify_account_dialog'
AutoRefreshDialog = require '../auto_refresh_dialog'
AdsenseAd = require '../adsense_ad'
FormatService = require '../../services/format'
DateService = require '../../services/date'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ProfileInfo
  constructor: (options) ->
    {@model, @router, user, player, @overlay$, gameKey, serverData} = options
    @$trophyIcon = new Icon()
    @$arenaIcon = new Icon()
    @$levelIcon = new Icon()
    @$fireIcon = new Icon()
    @$refreshIcon = new Icon()
    @$splitsInfoCard = new UiCard()
    @$moreDetailsButton = new PrimaryButton()
    @$verifyAccountButton = new SecondaryButton()
    @$clanBadge = new ClanBadge()
    @$dialog = new Dialog()
    @$verifyAccountDialog = new VerifyAccountDialog {@model, @router, @overlay$}
    @$autoRefreshDialog = new AutoRefreshDialog {
      @model, @router, @overlay$, gameKey
    }
    @$autoRefreshInfoIcon = new Icon()
    @$adsenseAd = new AdsenseAd {@model}

    isRequestNotificationCardVisible = new RxBehaviorSubject(
      window? and not Environment.isGameApp(config.GAME_KEY) and
        not localStorage?['hideNotificationCard']
    )
    @$requestNotificationsCard = new RequestNotificationsCard {
      @model
      isVisible: isRequestNotificationCardVisible
    }

    @$addonListItem1 = new AddonListItem {
      @model
      @router
      gameKey
      addon: @model.addon.getByKey 'cardCollection'
    }

    @$addonListItem2 = new AddonListItem {
      @model
      @router
      gameKey
      addon: @model.addon.getByKey 'deckBandit'
    }

    @state = z.state {
      isRequestNotificationCardVisible
      hasUpdatedPlayer: false
      isRefreshing: false
      isAutoRefresh: player.switchMap (player) =>
        @model.player.getIsAutoRefreshByPlayerIdAndGameId(
          player.id, config.CLASH_ROYALE_ID
        )
      isSplitsInfoCardVisible: window? and not localStorage?['hideSplitsInfo']
      user: user
      me: @model.user.getMe()
      gameKey: gameKey
      followingIds: @model.userFollower.getAllFollowingIds()
      player: player
      serverData: serverData
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
    ]

  render: =>
    {player, isRequestNotificationCardVisible, hasUpdatedPlayer, isRefreshing,
      isAutoRefresh, isSplitsInfoCardVisible, user, me, gameKey, serverData,
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
    userAgent = serverData?.req?.headers?['user-agent'] or
                  navigator?.userAgent or ''
    isNativeApp = Environment.isGameApp config.GAME_KEY, {userAgent}
    isMobile = Environment.isMobile {userAgent}
    arena = player?.data?.arena?.number % 1000

    z '.z-clash-royale-profile-info',
      z '.header',
        z '.g-grid',
          if document?.referrer
            if document.referrer.indexOf('clashroyalearena.com') isnt -1
              z '.referrer', 'Brought to you by Clash Royale Arena'
            else if document.referrer.indexOf('clashroyale-la.com') isnt -1
              z '.referrer', 'Traído hasta ti por Clash Royale Latino'
            else if document.referrer.indexOf('clashroyaledicas.com') isnt -1
              z '.referrer', 'Indicado por Clash Royale Dicas'
          z '.info',
            if player?.data?.clan
              z '.clan-badge',
                z @$clanBadge, {clan: player?.data?.clan, size: '32px'}
            z '.player',
              z '.name', player?.data?.name
              z '.tag-and-clan',
                "##{player?.id}"
                if player?.data?.clan
                  [
                    z 'span', innerHTML: ' &middot; '
                    player?.data?.clan.name
                  ]

              z '.stats',
                z '.trophies',
                  z '.text', player?.data?.trophies
                  z '.icon',
                    z @$trophyIcon,
                      icon: 'trophy'
                      size: '16px'
                      isTouchTarget: false
                      color: colors.$secondary500
                z '.level',
                  z '.text',
                    " #{player?.data?.expLevel or player?.data?.level}"
                  z '.icon',
                    z @$levelIcon,
                      icon: 'level'
                      size: '16px'
                      isTouchTarget: false
                      color: colors.$blue500

            z '.arena',
              style:
                backgroundImage:
                  "url(
                    #{config.CDN_URL}/arenas/#{arena}.png
                  )"
          z '.g-cols',
            # z '.g-col.g-xs-3', {
            #   onclick: =>
            #     @router.go 'fire', {gameKey}
            # },
            #   z '.icon',
            #     z @$fireIcon,
            #       icon: 'fire'
            #       color: colors.$secondary500
            #   z '.text',
            #     FormatService.number player?.fire
        z '.divider'
        z '.g-grid',
          z '.last-updated',
            z '.time',
              @model.l.get 'profileInfo.lastUpdatedTime'
              ' '
              DateService.fromNow lastUpdateTime
            z '.auto-refresh', {
              onclick: =>
                ga? 'send', 'event', 'verify', 'auto_refresh', 'click'
                @overlay$.next @$autoRefreshDialog
            },
              @model.l.get 'profileInfo.autoRefresh'
              ': '
              if isAutoRefresh
                z '.status',
                  @model.l.get 'general.on'
              else
                [
                  z '.status',
                    z 'div',
                      @model.l.get 'general.off'
                  z '.info',
                    z @$autoRefreshInfoIcon,
                      icon: 'help'
                      isTouchTarget: false
                      size: '14px'
                      color: colors.$white
                ]
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
                    @overlay$.next z @$dialog, {
                      isVanilla: true
                      $title: @model.l.get 'profileInfo.waitTitle'
                      $content: @model.l.get 'profileInfo.waitDescription', {
                        replacements:
                          number: '10'
                      }
                      onLeave: =>
                        @overlay$.next null
                      submitButton:
                        text: @model.l.get 'installOverlay.closeButtonText'
                        onclick: =>
                          @overlay$.next null
                    }

          if isMe and player and not player?.isVerified
            z '.verify-button',
              z @$verifyAccountButton,
                text: @model.l.get 'clanInfo.verifySelf'
                onclick: =>
                  @overlay$.next @$verifyAccountDialog
      z '.content',
        if isRequestNotificationCardVisible and isMe
          z '.card',
            z '.g-grid',
              z @$requestNotificationsCard

        if isMobile and not isNativeApp
          z '.ad',
            z @$adsenseAd, {
              slot: 'mobile300x250'
            }
        else if not isMobile and not isNativeApp
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
                      @router.go 'chestCycleByPlayerId', {
                        gameKey: gameKey
                        playerId: player?.id
                      }

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

        z '.block',
          z '.g-grid',
            z '.title', @model.l.get 'addonsPage.title'
            z '.addon',
              z @$addonListItem1, {
                hasPadding: false
                replacements: {playerTag: player?.id?.replace '#', ''}
              }
            z '.addon',
              z @$addonListItem2, {
                hasPadding: false
                replacements: {playerTag: player?.id?.replace '#', ''}
              }
