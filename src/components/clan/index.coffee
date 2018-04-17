z = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable

Tabs = require '../tabs'
Icon = require '../icon'
ClanInfo = require '../clan_info'
ClanMembers = require '../clan_members'
ClanGraphs = require '../clan_graphs'
ClaimClanDialog = require '../claim_clan_dialog'
ProfileDialog = require '../profile_dialog'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class Clan
  constructor: ({@model, @router, player}) ->
    me = @model.user.getMe()

    clan = player.switchMap (player) =>
      if player?.data?.clan?.tag
        @model.clan.getById player?.data?.clan?.tag?.replace('#', '')
        .map (clan) -> clan or false
      else
        RxObservable.of false

    @$tabs = new Tabs {@model}
    @$infoIcon = new Icon()
    @$membersIcon = new Icon()
    @$graphIcon = new Icon()

    selectedProfileDialogUser = new RxBehaviorSubject false

    @$selectedProfileDialog = new ProfileDialog {
      @model, @router, selectedProfileDialogUser
    }

    @overlay$ = new RxBehaviorSubject null

    @$clanInfo = new ClanInfo {
      @model, @router, clan, @overlay$
    }
    @$clanMembers = new ClanMembers {
      @model, @router, clan, selectedProfileDialogUser
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
