z = require 'zorium'
Rx = require 'rxjs'
_map = require 'lodash/map'
_uniq = require 'lodash/uniq'
_filter = require 'lodash/filter'
_find = require 'lodash/find'
_isEmpty = require 'lodash/isEmpty'

Icon = require '../icon'
Avatar = require '../avatar'
PrimaryButton = require '../primary_button'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class UserPicker
  constructor: ({@model, @router, @pickedStreams, users, gameKey}) ->

    @$findFriendsButton = new PrimaryButton()

    picked = @pickedStreams.switch()

    @state = z.state
      me: @model.user.getMe()
      gameKey: gameKey
      users: users.map (users) =>
        _map users, (user) =>
          {
            userInfo: user
            $avatar: new Avatar {@model}
            $checkIcon: new Icon()
          }
      picked: picked
      pickedWithComponents: picked.map (picked) =>
        _map picked, (user) =>
          {
            userInfo: user
            $avatar: new Avatar {@model}
            $checkIcon: new Icon()
          }

  render: ({isUnavailableFn, unavailableMessage, isSelectAllEnabled,
      noUsersMessage, title} = {}) =>

    {me, picked, pickedWithComponents, users, gameKey} = @state.getValue()

    isUsersEmpty = Boolean users
    users ?= []
    pickedWithComponents ?= []
    userSuggestions = users.concat pickedWithComponents
    # merge any 'to' users that aren't already in users
    userSuggestions = _uniq userSuggestions, ({userInfo}) ->
      userInfo.id

    title ?= 'User suggestions'
    noUsersMessage ?= z '.z-user-picker_no-users',
      'No users found :( Maybe add some friends?'
      z '.find-friends',
        z @$findFriendsButton,
          text: 'Find Friends'
          onclick: =>
            @router.go 'friendsWithAction', 'friends', {
              gameKey, action: 'find'
            }

    z '.z-user-picker',
      z '.top',
        z '.title', title
        if isSelectAllEnabled and picked?.length < userSuggestions?.length and
            userSuggestions?.length > 1
          z '.select-all', {
            onclick: =>
              selectedUsers = _filter _map userSuggestions, ({userInfo}) ->
                isUnavailable = if isUnavailableFn \
                                then isUnavailableFn(userInfo)
                                else false
                unless isUnavailable
                  userInfo
              @pickedStreams.next \
                Rx.Observable.of selectedUsers
          },
            'Select all'
      if isUsersEmpty and _isEmpty userSuggestions
        noUsersMessage
      else
        _map userSuggestions, ({userInfo, $avatar, $checkIcon}) =>
          isChecked = _find(picked, {id: userInfo.id})

          isUnavailable = if isUnavailableFn \
                          then isUnavailableFn(userInfo)
                          else false

          z '.user', {
            className: z.classKebab {isUnavailable}
            onclick: =>
              if isUnavailable
                return
              if isChecked
                newTo = _filter picked, ({id}) ->
                  not id or id isnt userInfo.id
                @pickedStreams.next Rx.Observable.of newTo
              else
                @pickedStreams.next \
                  Rx.Observable.of picked.concat [userInfo]
          },
            z '.avatar',
              z $avatar, {user: userInfo, bgColor: colors.$grey200}
            z '.name',
              @model.user.getDisplayName userInfo
              if isUnavailable
                z '.unavailable-message', unavailableMessage
            z '.checkbox', {
              className: z.classKebab {isChecked}
            },
              if isChecked
                z $checkIcon,
                  icon: 'check'
                  isTouchTarget: false
                  color: colors.$white
                  size: '14px'
