z = require 'zorium'
Rx = require 'rx-lite'
_find = require 'lodash/find'

ClaimClanDialog = require '../claim_clan_dialog'
JoinGroupDialog = require '../join_group_dialog'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class VerifyAccountDialog
  constructor: ({@model, @router, @overlay$}) ->
    me = @model.user.getMe()
    player = me.flatMapLatest ({id}) =>
      @model.player.getByUserIdAndGameId id, config.CLASH_ROYALE_ID

    clan = player.flatMapLatest (player) =>
      if player?.data?.clan?.tag
        @model.clan.getById player?.data?.clan?.tag?.replace('#', '')
        .map (clan) -> clan or false
      else
        Rx.Observable.just false

    @$joinGroupDialog = new JoinGroupDialog {@model, @router, @overlay$, clan}
    @$claimClanDialog = new ClaimClanDialog {@model, @router, @overlay$, clan}

    @state = z.state {clan, player}

  render: =>
    {clan, player} = @state.getValue()

    clanPlayer = _find clan?.data?.memberList, {tag: "##{player?.id}"}
    isLeader = clanPlayer?.role in ['coLeader', 'leader']

    z '.z-verify-account-dialog',
      if isLeader
        @$claimClanDialog
      else if clanPlayer
        @$joinGroupDialog
