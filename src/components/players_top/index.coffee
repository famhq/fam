z = require 'zorium'
Rx = require 'rx-lite'

PlayerList = require '../player_list'
SearchInput = require '../search_input'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class PlayersTop
  constructor: ({@model, @router, @selectedProfileDialogUser}) ->
    @$searchInput = new SearchInput {}

    @$playerList = new PlayerList {
      @model
      @selectedProfileDialogUser
      players: @model.player.getTop()
    }

  render: =>

    z '.z-players-top',
      z '.g-grid',
        z '.search',
          z @$searchInput, {
            isSearchIconRight: true
            height: '36px'
            bgColor: colors.$tertiary500
            onclick: =>
              @router.go '/players/search'
            placeholder: 'Find player...'
          }
        z @$playerList, {
          onclick: ({player}) =>
            userId = player?.verifiedUserId or player?.userIds?[0]
            @router.go "/user/id/#{userId}"

        }
        # _map players, (player) ->
        #   z '.player',
        #     z '.rank', player.rank
        #     z '.name', player.data.name
