z = require 'zorium'
Rx = require 'rx-lite'
_isEmpty = require 'lodash/isEmpty'

UserList = require '../user_list'
TopFriends = require '../top_friends'
Icon = require '../icon'
colors = require '../../colors'

if window?
  require './index.styl'

SEARCH_DEBOUNCE = 300

module.exports = class FindFriends
  constructor: ({model, @isFindFriendsVisible, selectedProfileDialogUser}) ->
    @isFindFriendsVisible ?= new Rx.BehaviorSubject true
    @searchValue = new Rx.BehaviorSubject ''

    # TODO: add infinite scroll
    # tried comblineLatest w/ debounce stream and onscrollbottom stream,
    # couldn't get it working
    users = @searchValue.debounce(SEARCH_DEBOUNCE).flatMapLatest (query) ->
      if query
        model.user.searchByUsername query
      else
        Rx.Observable.just []

    @$icon = new Icon()
    @$clear = new Icon()

    @$userList = new UserList {
      model, users, selectedProfileDialogUser
    }
    @$topFriends = new TopFriends {model, selectedProfileDialogUser}

    @state = z.state
      searchValue: @searchValue
      users: users

  afterMount: (@$$el) =>
    @$$el.querySelector('.input').focus()

  clear: =>
    @searchValue.onNext ''
    @$$el.querySelector('.input').focus()

  render: ({onclick, onBack, showCurrentFriends} = {}) =>
    showCurrentFriends ?= false

    {searchValue, users} = @state.getValue()

    z '.z-find-friends', {
      style:
        height: "#{window?.innerHeight}px"
    },
      z '.overlay',
        z 'span.left-icon',
          z @$icon,
            icon: 'back'
            isAlignedTop: true
            isAlignedLeft: true
            color: colors.$primary900
            onclick: =>
              onBack?() or @isFindFriendsVisible.onNext Rx.Observable.just false
        z 'span.right-icon',
          unless _isEmpty searchValue
            z @$clear,
              icon: 'close'
              isAlignedTop: true
              isAlignedRight: true
              color: colors.$primary500
              onclick: @clear
      z 'form.form',
        onsubmit: (e) ->
          e.preventDefault()
          document.activeElement.blur() # hide keyboard
        z 'input.input',
          placeholder: 'Search by username'
          value: searchValue
          onfocus: @open
          focused: 'focused'
          oninput: z.ev (e, $$el) =>
            @searchValue.onNext $$el.value
      z '.results',
        if _isEmpty users
          z 'div',
            z @$topFriends, {onclick}
        else
          z 'div', z @$userList, {onclick}
