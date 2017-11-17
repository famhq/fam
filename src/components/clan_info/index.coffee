z = require 'zorium'
_startCase = require 'lodash/startCase'
_find = require 'lodash/find'
Environment = require 'clay-environment'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
require 'rxjs/add/operator/switchMap'


Icon = require '../icon'
AdsenseAd = require '../adsense_ad'
RequestNotificationsCard = require '../request_notifications_card'
AddonListItem = require '../addon_list_item'
PrimaryButton = require '../primary_button'
SecondaryButton = require '../secondary_button'
ClanMetrics = require '../clan_metrics'
VerifyAccountDialog = require '../verify_account_dialog'
FormatService = require '../../services/format'
DateService = require '../../services/date'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ClanInfo
  constructor: ({@model, @router, clan, @overlay$, gameKey}) ->
    @$trophyIcon = new Icon()
    @$donationsIcon = new Icon()
    @$membersIcon = new Icon()
    @$refreshIcon = new Icon()
    @$claimButton = new PrimaryButton()
    @$chatButton = new SecondaryButton()
    @$adsenseAd = new AdsenseAd {@model}

    isRequestNotificationCardVisible = new RxBehaviorSubject(
      window? and not Environment.isGameApp(config.GAME_KEY) and
        not localStorage?['hideNotificationCard']
    )
    @$requestNotificationsCard = new RequestNotificationsCard {
      @model
      isVisible: isRequestNotificationCardVisible
    }

    @$addonListItem = new AddonListItem {
      @model
      @router
      gameKey
      addon: @model.addon.getByKey 'clanManager'
    }

    @$verifyAccountDialog = new VerifyAccountDialog {@model, @router, @overlay$}

    @$clanMetrics = new ClanMetrics {@model, @router, clan}

    me = @model.user.getMe()

    @state = z.state {
      isRequestNotificationCardVisible
      me: me
      hasUpdatedClan: false
      gameKey: gameKey
      mePlayer: me.switchMap ({id}) =>
        @model.player.getByUserIdAndGameId id, config.CLASH_ROYALE_ID
      clan: clan
    }

  render: =>
    {isSplitsInfoCardVisible, clan, mePlayer, me, gameKey,
      hasUpdatedClan, isRefreshing} = @state.getValue()

    mePlayerIsVerified = mePlayer?.isVerified
    clanPlayer = _find clan?.data?.memberList, {tag: "##{mePlayer?.id}"}
    isLeader = clanPlayer?.role in ['coLeader', 'leader']
    isCreator = clan?.creatorId is me?.id

    isClaimed = clan?.creatorId
    hasPermission = clan?.group?.userIds?.indexOf(me?.id) isnt -1

    memberCount = clan?.data?.memberList?.length or
      clan?.players?.length # legacy

    z '.z-clan-info',
      z '.header',
        z '.g-grid',
          z '.info',
            z '.left',
              z '.name', clan?.data?.name
              z '.tag', "##{clan?.clanId}"
            if clan?.data?.clan
              z '.right',
                z '.clan-name', clan?.data?.clan.name
                z '.clan-tag', "##{clan?.data?.clan.tag}"
          z '.g-cols',
            z '.g-col.g-xs-4',
              z '.icon',
                z @$trophyIcon,
                  icon: 'trophy'
                  color: colors.$secondary500
              z '.text', FormatService.number(
                clan?.data?.clanScore or
                clan?.data?.trophies # legacy
              )
            z '.g-col.g-xs-4',
              z '.icon',
                z @$donationsIcon,
                  icon: 'cards'
                  color: colors.$secondary500
              z '.text', FormatService.number(
                clan?.data?.donationsPerWeek or
                clan?.data?.donations or 0 # legacy
              )
              if clan?.data?.league
                z '.text', clan?.data?.league?.name
            z '.g-col.g-xs-4',
              z '.icon',
                z @$membersIcon,
                  icon: 'friends'
                  color: colors.$secondary500
              z '.text', "#{memberCount} / 50"

        z '.divider'
        z '.g-grid',
          z '.last-updated',
            z '.time',
              @model.l.get 'clanInfo.lastUpdatedTime'
              ' '
              DateService.fromNow clan?.lastUpdateTime
            if @model.clan.canRefresh clan, hasUpdatedClan
              z '.refresh',
                if isRefreshing
                  '...'
                else
                  z @$refreshIcon,
                    icon: 'refresh'
                    isTouchTarget: false
                    color: colors.$primary500
                    onclick: =>
                      clanId = clan?.clanId
                      @state.set isRefreshing: true
                      @model.clashRoyaleAPI.refreshByClanId clanId
                      .then =>
                        @state.set hasUpdatedClan: true, isRefreshing: false

          if (isLeader and not isClaimed) or
              (isCreator and isClaimed and not clan.password) or
              (clanPlayer and isClaimed and not isLeader)
            z '.claim-button',
              z @$claimButton,
                text: @model.l.get 'clanInfo.claimClan'
                onclick: =>
                  @model.signInDialog.openIfGuest me
                  .then =>
                    @overlay$.next @$verifyAccountDialog

          if clanPlayer and hasPermission
            z '.claim-button',
              z @$chatButton,
                text: @model.l.get 'clanInfo.clanChat'
                onclick: =>
                  @router.go 'groupChat', {gameKey, id: clan.groupId}
      z '.content',
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

        z '.block',
          z '.g-grid',
            z '.description', clan?.data?.description

        z '.divider'
        z '.block',
          z @$clanMetrics

        z '.block',
          z '.g-grid',
            z '.title', @model.l.get 'addonsPage.title'
            z @$addonListItem, {
              hasPadding: false
              replacements: {clanTag: clan?.id.replace '#', ''}
            }
