z = require 'zorium'
Rx = require 'rxjs'

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
  constructor: ({@model, @router, clan, gameKey}) ->
    me = @model.user.getMe()

    @$tabs = new Tabs {@model}
    @$infoIcon = new Icon()
    @$membersIcon = new Icon()
    @$graphIcon = new Icon()

    selectedProfileDialogUser = new Rx.BehaviorSubject false

    @$selectedProfileDialog = new ProfileDialog {
      @model, @router, selectedProfileDialogUser, gameKey
    }

    @overlay$ = new Rx.BehaviorSubject null

    @$clanInfo = new ClanInfo {
      @model, @router, clan, @overlay$, gameKey
    }
    @$clanMembers = new ClanMembers {
      @model, @router, clan, selectedProfileDialogUser, gameKey
    }
    @$clanGraphs = new ClanGraphs {@model, @router, clan}

    @state = z.state
      me: me
      overlay$: @overlay$
      selectedProfileDialogUser: selectedProfileDialogUser

  render: ({isOtherClan} = {}) =>
    {me, selectedProfileDialogUser, overlay$} = @state.getValue()

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

      if overlay$
        overlay$
