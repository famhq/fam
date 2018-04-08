z = require 'zorium'
_isEmpty = require 'lodash/isEmpty'
_map = require 'lodash/map'
_truncate = require 'lodash/truncate'
_filter = require 'lodash/filter'
_find = require 'lodash/find'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/observable/combineLatest'
require 'rxjs/add/operator/switchMap'
require 'rxjs/add/operator/map'

Base = require '../base'
Icon = require '../icon'
Avatar = require '../avatar'
Spinner = require '../spinner'
FormatService = require '../../services/format'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

MAX_TITLE_LENGTH = 60

module.exports = class GroupLeaderboard
  constructor: ({@model, @router, group}) ->
    @$spinner = new Spinner()

    me = @model.user.getMe()
    groupAndMe = RxObservable.combineLatest(
      group
      me
      (vals...) -> vals
    )
    leaderboardGroupUsers = group.switchMap (group) =>
      @model.groupUser.getTopByGroupId group.id

    @state = z.state
      me: @model.user.getMe()
      meGroupUser: groupAndMe.switchMap ([group, me]) =>
        @model.groupUser.getByGroupIdAndUserId group.id, me.id
      leaderboardGroupUsers: leaderboardGroupUsers.map (groupUsers) ->
        _map groupUsers, (groupUser) ->
          {
            groupUser
            $avatar: new Avatar()
          }

  render: =>
    {me, meGroupUser, leaderboardGroupUsers} = @state.getValue()

    currentXp = meGroupUser?.xp or 0
    level = _find(config.XP_LEVEL_REQUIREMENTS, ({xpRequired}) ->
      currentXp >= xpRequired
    )?.level
    nextLevel = _find config.XP_LEVEL_REQUIREMENTS, {level: level + 1}
    nextLevelXp = nextLevel?.xpRequired
    xpPercent = 100 * currentXp / nextLevelXp

    z '.z-group-leaderboard',
      z '.g-grid',
        z '.bar',
          z '.fill',
            style:
              width: "#{xpPercent}%"
          z '.progress',
            @model.l.get 'general.level'
            ": #{level}"
            ' ('
            FormatService.number currentXp
            ' / '
            "#{nextLevelXp}xp"
            ')'
        z '.leaderboard',
          if leaderboardGroupUsers and _isEmpty leaderboardGroupUsers
            z '.no-users', 'No users found'
          else if leaderboardGroupUsers
            _map leaderboardGroupUsers, ({groupUser, $avatar}, i) =>
              [
                z '.user', {
                  onclick: ->
                    null
                },
                  z '.rank', groupUser.rank
                  z '.avatar',
                    z $avatar, {user: groupUser.user, groupUser}
                  z '.name',
                    @model.user.getDisplayName groupUser.user
                  z '.xp',
                    groupUser.xp
              ]
          else
            @$spinner
