z = require 'zorium'
_map = require 'lodash/map'
_startCase = require 'lodash/startCase'
Rx = require 'rx-lite'
Environment = require 'clay-environment'

Icon = require '../icon'
UiCard = require '../ui_card'
RequestNotificationsCard = require '../request_notifications_card'
PrimaryButton = require '../primary_button'
FormatService = require '../../services/format'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ProfileInfo
  constructor: ({@model, @router, clan}) ->
    @$trophyIcon = new Icon()
    @$donationsIcon = new Icon()
    @$membersIcon = new Icon()
    @$splitsInfoCard = new UiCard()

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
      # isSplitsInfoCardVisible: window? and not localStorage?['hideClanSplitsInfo']
      me: @model.user.getMe()
      clan: clan
    }

  render: =>
    {isSplitsInfoCardVisible, clan, me} = @state.getValue()

    isMe = clan?.id and clan?.id is me?.id

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

    console.log clan

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
