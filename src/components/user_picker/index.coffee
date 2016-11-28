z = require 'zorium'
Rx = require 'rx-lite'
colors = require '../../colors'
Button = require 'zorium-paper/button'
_map = require 'lodash/collection/map'
_uniq = require 'lodash/array/uniq'
_filter = require 'lodash/collection/filter'
_find = require 'lodash/collection/find'
_isEmpty = require 'lodash/lang/isEmpty'
log = require 'loga'
Environment = require 'clay-environment'

config = require '../../config'
Icon = require '../icon'
Spinner = require '../spinner'
Avatar = require '../avatar'
PrimaryButton = require '../primary_button'

if window?
  require './index.styl'

module.exports = class UserPicker
  constructor: ({@model, @router, @pickedStreams, users}) ->

    # @$spinner = new Spinner()
    @$pickFromKikButton = new Button()
    @$findFriendsButton = new PrimaryButton()

    picked = @pickedStreams.switch()

    @state = z.state
      me: @model.user.getMe()
      isKikInstalled: if window?
      then Rx.Observable.fromPromise @model.portal.call 'kik.isInstalled'
      else null
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

    {me, picked, pickedWithComponents, users,
      isKikInstalled} = @state.getValue()

    isUsersEmpty = Boolean users
    users ?= []
    pickedWithComponents ?= []
    userSuggestions = users.concat pickedWithComponents
    # merge any 'to' users that aren't already in users
    userSuggestions = _uniq userSuggestions, ({userInfo}) ->
      "#{userInfo.id}:#{userInfo.kikUsername}"

    title ?= 'User suggestions'
    noUsersMessage ?= z '.z-user-picker_no-users',
      'No users found :( Maybe add some friends?'
      z '.find-friends',
        z @$findFriendsButton,
          text: 'Find Friends'
          onclick: =>
            @router.go '/friends/find'

    z '.z-user-picker',
      if isKikInstalled
        z '.pick-from-kik',
          z @$pickFromKikButton,
            text: 'Pick friends from Kik'
            isRaised: true
            isFullWidth: true
            isDark: true
            onclick: =>
              @model.portal.call 'kik.sendViral'
              .then (users) =>
                newUsers = _map users, ({username, pic}) -> {
                  kikUsername: username
                  data:
                    avatar: pic
                }
                @pickedStreams.onNext \
                  Rx.Observable.just picked.concat newUsers
            colors:
              cText: '#82bc23'
              c200: colors.$grey100
              c500: colors.$white
              c600: colors.$grey200
              c700: colors.$grey300

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
              @pickedStreams.onNext \
                Rx.Observable.just selectedUsers
          },
            'Select all'
      if isUsersEmpty and _isEmpty userSuggestions
        noUsersMessage
      else
        _map userSuggestions, ({userInfo, $avatar, $checkIcon}) =>
          isChecked = _find(picked, {id: userInfo.id}) or
            (userInfo.kikUsername and
            _find(picked, {kikUsername: userInfo.kikUsername}))

          isUnavailable = if isUnavailableFn \
                          then isUnavailableFn(userInfo)
                          else false

          z '.user', {
            className: z.classKebab {isUnavailable}
            onclick: =>
              if isUnavailable
                return
              if isChecked
                newTo = _filter picked, ({id, kikUsername}) ->
                  (not id or id isnt userInfo.id) and (
                    not kikUsername or kikUsername isnt userInfo.kikUsername
                  )
                @pickedStreams.onNext Rx.Observable.just newTo
              else
                @pickedStreams.onNext \
                  Rx.Observable.just picked.concat [userInfo]
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
