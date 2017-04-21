z = require 'zorium'
_map = require 'lodash/map'
_startCase = require 'lodash/startCase'
_find = require 'lodash/find'
Rx = require 'rx-lite'
Environment = require 'clay-environment'
moment = require 'moment'

Icon = require '../icon'
UiCard = require '../ui_card'
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
    @$splitsInfoCard = new UiCard()
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

    mePlayerIsVerified = mePlayer?.verifiedUserId is me?.id
    clanPlayer = _find clan?.players, {playerId: mePlayer?.playerId}
    isLeader = clanPlayer?.role in ['coLeader', 'leader']

    isClaimed = clan?.groupId

    metrics =
      stats: [
        # {
        #   name: 'Donations this wk'
        #   value: FormatService.number clan?.data?.donation
        # }
        {
          name: 'Type'
          value: _startCase clan?.data?.type
        }
        {
          name: 'Required trophies'
          value: FormatService.number clan?.data?.minTrophies
        }
        {
          name: 'Location'
          value: clan?.data?.region
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
              'Last updated '
              moment(clan?.lastUpdateTime).fromNowModified()
            if clan?.isUpdatable and not hasUpdatedClan and isLeader
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
                text: 'Claim clan'
                onclick: =>
                  @model.signInDialog.openIfGuest me
                  .then =>
                    @isClaimClanDialogVisible.onNext true
          else if mePlayerIsVerified and clanPlayer and isClaimed
            z '.claim-button',
              z @$claimButton,
                text: 'Clan chat'
                onclick: =>
                  @router.go "/group/#{clan.groupId}/chat"
          else if clanPlayer and isClaimed
            z '.claim-button',
              z @$claimButton,
                text: 'Verify self'
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
              # if key is 'ladder' and isSplitsInfoCardVisible
              #   z '.splits-info-card',
              #     z @$splitsInfoCard,
              #       text: 'Note: The stats below will only account for your
              #             previous 25 games initially. All future stats will
              #             be tracked.'
              #       submit:
              #         text: 'got it'
              #         onclick: =>
              #           @state.set isSplitsInfoCardVisible: false
              #           localStorage?['hideClanSplitsInfo'] = '1'
              z '.title',
                _startCase key
              z '.g-cols',
                _map stats, ({name, value}) ->
                  z '.g-col.g-xs-6',
                    z '.name', name
                    z '.value', value
