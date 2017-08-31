z = require 'zorium'
Rx = require 'rx-lite'

Tabs = require '../tabs'
Icon = require '../icon'
ClanInfo = require '../clan_info'
ClanMembers = require '../clan_members'
ClanGraphs = require '../clan_graphs'
ClaimClanDialog = require '../claim_clan_dialog'
JoinGroupDialog = require '../join_group_dialog'
ProfileDialog = require '../profile_dialog'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class Clan
  constructor: ({@model, @router, clan}) ->
    me = @model.user.getMe()

    @$tabs = new Tabs {@model}
    @$infoIcon = new Icon()
    @$membersIcon = new Icon()
    @$graphIcon = new Icon()

    selectedProfileDialogUser = new Rx.BehaviorSubject false

    @$selectedProfileDialog = new ProfileDialog {
      @model, @router, selectedProfileDialogUser
    }

    isClaimClanDialogVisible = new Rx.BehaviorSubject false

    @$claimClanDialog = new ClaimClanDialog {
      @model, @router
      isVisible: isClaimClanDialogVisible
      clan
    }

    isJoinGroupDialogVisible = new Rx.BehaviorSubject false

    @$joinGroupDialog = new JoinGroupDialog {
      @model, @router
      isVisible: isJoinGroupDialogVisible
      clan
    }

    @$clanInfo = new ClanInfo {
      @model, @router, clan, isClaimClanDialogVisible, isJoinGroupDialogVisible
    }
    @$clanMembers = new ClanMembers {
      @model, @router, clan, selectedProfileDialogUser
    }
    @$clanGraphs = new ClanGraphs {@model, @router, clan}

    @state = z.state
      me: me
      isClaimClanDialogVisible: isClaimClanDialogVisible
      isJoinGroupDialogVisible: isJoinGroupDialogVisible
      selectedProfileDialogUser: selectedProfileDialogUser

  render: ({isOtherClan} = {}) =>
    {me, selectedProfileDialogUser, isClaimClanDialogVisible,
      isJoinGroupDialogVisible} = @state.getValue()

    z '.z-clan',
      z @$tabs,
        isBarFixed: false
        isBarFlat: false
        barStyle: 'primary'
        tabs: [
          {
            $menuIcon: @$infoIcon
            menuIconName: 'info'
            $menuText: @model.l.get 'general.info'
            $el: @$clanInfo
          }
          {
            $menuIcon: @$membersIcon
            menuIconName: 'friends'
            $menuText: @model.l.get 'general.members'
            $el: @$clanMembers
          }
          {
            $menuIcon: @$graphIcon
            menuIconName: 'stats'
            $menuText: @model.l.get 'general.graphs'
            $el: @$clanGraphs
          }
        ]
      if selectedProfileDialogUser
        @$selectedProfileDialog

      if isClaimClanDialogVisible
        @$claimClanDialog

      if isJoinGroupDialogVisible
        @$joinGroupDialog
