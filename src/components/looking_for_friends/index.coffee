z = require 'zorium'
_isEmpty = require 'lodash/isEmpty'

PlayerList = require '../player_list'
PrimaryButton = require '../primary_button'
SearchInput = require '../search_input'
LookingForFriendsDialog = require '../looking_for_friends_dialog'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class LookingForFriends
  constructor: ({@model, @router, @overlay$}) ->
    players = @model.l.getLanguage().flatMapLatest (language) =>
      @model.findFriend.getAll {language}

    @$searchInput = new SearchInput {@model}
    @$shareLinkButton = new PrimaryButton()
    @$lookingForFriendsDialog = new LookingForFriendsDialog {
      @model, @router, @overlay$
    }
    @$playerList = new PlayerList {
      @model
      players: players
    }

    @state = z.state {players}

  render: =>
    {players} = @state.getValue()

    z '.z-looking-for-friends',
      z '.g-grid', [
        z '.search',
          z @$searchInput, {
            isSearchIconRight: true
            height: '36px'
            bgColor: colors.$tertiary500
            onclick: =>
              @router.go '/players/search'
            placeholder: 'Find player...'
          }
        # if players and _isEmpty players
        #   z '.empty-state',
        #     z '.image'
        #     z 'div', @model.l.get 'playersFollowing.emptyDiv1'
        #     z 'div',
        #       @model.l.get 'playersFollowing.emptyDiv2'
        # else
        #   [
        z '.subhead', @model.l.get 'lookingForFriends.subhead'
        z '.button',
          z @$shareLinkButton,
            text: @model.l.get 'lookingForFriends.shareLink'
            onclick: =>
              @overlay$.onNext @$lookingForFriendsDialog

        z @$playerList, {
          onclick: (findFriend) =>
            token = findFriend?.token
            @model.portal.call 'browser.openWindow',
              target: '_system'
              url: 'clashroyale://add_friend' +
                    "?tag=#{findFriend.playerId}&token=#{token}"
        }
          # ]
      ]
