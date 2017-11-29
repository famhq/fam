z = require 'zorium'
_isEmpty = require 'lodash/isEmpty'
_map = require 'lodash/map'
_truncate = require 'lodash/truncate'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/operator/switchMap'
require 'rxjs/add/operator/map'

Base = require '../base'
Icon = require '../icon'
Avatar = require '../avatar'
Spinner = require '../spinner'
FormatService = require '../../services/format'
colors = require '../../colors'

if window?
  require './index.styl'

MAX_TITLE_LENGTH = 60

module.exports = class GroupLeaderboard
  constructor: ({@model, @router, group, sort, filter}) ->
    @$spinner = new Spinner()

    me = @model.user.getMe()
    leaderboardGroupUsers = group.switchMap (group) =>
      @model.groupUser.getTopByGroupId group.id

    @state = z.state
      me: @model.user.getMe()
      leaderboardGroupUsers: leaderboardGroupUsers.map (groupUsers) ->
        _map groupUsers, (groupUser) ->
          {
            groupUser
            $avatar: new Avatar()
          }

  render: =>
    {me, leaderboardGroupUsers} = @state.getValue()

    z '.z-group-leaderboard',
      z '.g-grid',
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
