z = require 'zorium'
Rx = require 'rx-lite'

Tabs = require '../tabs'
Icon = require '../icon'
ClanInfo = require '../clan_info'
ClanMembers = require '../clan_members'
ClanGraphs = require '../clan_graphs'
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

    @$clanInfo = new ClanInfo {@model, @router, clan}
    @$clanMembers = new ClanMembers {
      @model, @router, clan, selectedProfileDialogUser
    }
    @$clanGraphs = new ClanGraphs {@model, @router, clan}

    @state = z.state
      me: me
      selectedProfileDialogUser: selectedProfileDialogUser

  render: ({isOtherClan} = {}) =>
    {me, selectedProfileDialogUser} = @state.getValue()

    z '.z-clan',
      z @$tabs,
        isBarFixed: false
        isBarFlat: false
        barStyle: if isOtherClan then 'secondary' else 'primary'
        tabs: [
          {
            $menuIcon: @$infoIcon
            menuIconName: 'info'
            $menuText: 'Info'
            $el: @$clanInfo
          }
          {
            $menuIcon: @$membersIcon
            menuIconName: 'friends'
            $menuText: 'Members'
            $el: @$clanMembers
          }
          {
            $menuIcon: @$graphIcon
            menuIconName: 'stats'
            $menuText: 'Graphs'
            $el: @$clanGraphs
          }
        ]
      if selectedProfileDialogUser
        @$selectedProfileDialog
