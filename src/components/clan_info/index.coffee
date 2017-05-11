z = require 'zorium'
_map = require 'lodash/map'
_startCase = require 'lodash/startCase'
_find = require 'lodash/find'
_filter = require 'lodash/filter'
Rx = require 'rx-lite'
Environment = require 'clay-environment'
moment = require 'moment'

Icon = require '../icon'
RequestNotificationsCard = require '../request_notifications_card'
PrimaryButton = require '../primary_button'
FormatService = require '../../services/format'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ClanInfo
  constructor: (options) ->
    {@model, @router, clan, @isClaimClanDialogVisible,
      @isJoinGroupDialogVisible} = options
    @$trophyIcon = new Icon()
    @$donationsIcon = new Icon()
    @$membersIcon = new Icon()
    @$refreshIcon = new Icon()
    @$claimButton = new PrimaryButton()

    isRequestNotificationCardVisible = new Rx.BehaviorSubject(
      window? and not Environment.isGameApp(config.GAME_KEY) and
        not localStorage?['hideNotificationCard']
    )
    @$requestNotificationsCard = new RequestNotificationsCard {
      @model
      isVisible: isRequestNotificationCardVisible
    }

    me = @model.user.getMe()

    @state = z.state {
      isRequestNotificationCardVisible
      @isClaimClanDialogVisible
      # isSplitsInfoCardVisible: window? and not localStorage?['hideClanSplitsInfo']
      me: me
      hasUpdatedClan: false
      isUpdatable: false
      mePlayer: me.flatMapLatest ({id}) =>
        @model.player.getByUserIdAndGameId id, config.CLASH_ROYALE_ID
      clan: clan
    }

  render: =>
    {isSplitsInfoCardVisible, clan, mePlayer, me,
      hasUpdatedClan, isRefreshing} = @state.getValue()

    isMe = clan?.id and clan?.id is me?.id

    mePlayerIsVerified = mePlayer?.isVerified
    clanPlayer = _find clan?.players, {playerId: mePlayer?.id}
    isLeader = clanPlayer?.role in ['coLeader', 'leader']

    isClaimed = clan?.groupId

    metrics =
      info: _filter [
        # {
        #   name: 'Donations this wk'
        #   value: FormatService.number clan?.data?.donation
        # }
        {
          name: @model.l.get 'clanInfo.type'
          value: _startCase clan?.data?.type
        }
        {
          name: @model.l.get 'clanInfo.minTrophies'
          value: FormatService.number clan?.data?.minTrophies
        }
        {
          name: @model.l.get 'clanInfo.region'
          value: clan?.data?.region
        }
        if clan?.password
          {
            name: @model.l.get 'general.password'
            value: clan?.password
          }
      ]

    memberCount = clan?.players?.length

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
              z '.text', FormatService.number clan?.data?.trophies
            z '.g-col.g-xs-4',
              z '.icon',
                z @$donationsIcon,
                  icon: 'cards'
                  color: colors.$secondary500
              z '.text', FormatService.number clan?.data?.donations
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
              @model.l.get 'clanInfo.lastUpdateTime'
              moment(clan?.lastUpdateTime).fromNowModified()
            if clan?.isUpdatable and not hasUpdatedClan
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

          if isLeader and not isClaimed
            z '.claim-button',
              z @$claimButton,
                text: @model.l.get 'clanInfo.claimClan'
                onclick: =>
                  @model.signInDialog.openIfGuest me
                  .then =>
                    @isClaimClanDialogVisible.onNext true
          else if mePlayerIsVerified and clanPlayer and isClaimed
            z '.claim-button',
              z @$claimButton,
                text: @model.l.get 'clanInfo.clanChat'
                onclick: =>
                  @router.go "/group/#{clan.groupId}/chat"
          else if clanPlayer
            z '.claim-button',
              z @$claimButton,
                text: @model.l.get 'clanInfo.verifySelf'
                onclick: =>
                  @model.signInDialog.openIfGuest me
                  .then =>
                    @isJoinGroupDialogVisible.onNext true
      z '.content',
        z '.block',
          z '.g-grid',
            z '.description', clan?.data?.description
        z '.divider'
        z '.block',
          _map metrics, (stats, key) ->
            z '.g-grid',
              z '.title',
                _startCase key
              z '.g-cols',
                _map stats, ({name, value}) ->
                  z '.g-col.g-xs-6',
                    z '.name', name
                    z '.value', value
