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
RequestNotificationsCard = require '../request_notifications_card'
ClanBadge = require '../clan_badge'
PrimaryButton = require '../primary_button'
SecondaryButton = require '../secondary_button'
AddonListItem = require '../addon_list_item'
VerifyAccountDialog = require '../verify_account_dialog'
ClashRoyaleChestCycle = require '../clash_royale_chest_cycle'
ProfileRefreshBar = require '../profile_refresh_bar'
AdsenseAd = require '../adsense_ad'
FormatService = require '../../services/format'
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
    @$splitsInfoCard = new UiCard()
    @$moreDetailsButton = new PrimaryButton()
    @$verifyAccountButton = new SecondaryButton()
    @$clanBadge = new ClanBadge()
    @$verifyAccountDialog = new VerifyAccountDialog {@model, @router, @overlay$}
    @$clashRoyaleChestCycle = new ClashRoyaleChestCycle {
      @model, @router, player
    }
    @$profileRefreshBar = new ProfileRefreshBar {
      @model, @router, player, @overlay$
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
      isSplitsInfoCardVisible: window? and not localStorage?['hideSplitsInfo']
      user: user
      me: @model.user.getMe()
      gameKey: gameKey
      followingIds: @model.userFollower.getAllFollowingIds()
      player: player
      serverData: serverData
    }

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
    {player, isRequestNotificationCardVisible,
      isSplitsInfoCardVisible, user, me, gameKey, serverData,
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
                  if arena
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
          z '.profile-refresh-bar',
            @$profileRefreshBar

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

        z '.block',
          z '.g-grid',
            z '.title', @model.l.get 'profileChests.chestsTitle'
            z @$clashRoyaleChestCycle, {
              showAll: true
            }

        z '.block',
          _map metrics, (stats, key) =>
            z '.g-grid',
              if key is 'ladder' and isSplitsInfoCardVisible
                z '.splits-info-card',
                  z @$splitsInfoCard,
                    $content: @model.l.get 'profileInfo.splitsInfoCardText'
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
