_isEmpty = require 'lodash/lang/isEmpty'
z = require 'zorium'
Rx = require 'rx-lite'
colors = require '../../colors'

UserList = require '../user_list'
Icon = require '../icon'

if window?
  require './index.styl'

SEARCH_DEBOUNCE = 300

module.exports = class FindFriends
  constructor: ({model, portal, @isFindFriendsVisible,
      selectedProfileDialogUser}) ->

    @value = new Rx.BehaviorSubject ''

    # TODO: add infinite scroll
    # tried comblineLatest w/ debounce stream and onscrollbottom stream,
    # couldn't get it working
    users = @value.debounce(SEARCH_DEBOUNCE).flatMapLatest (query) ->
      ga? 'send', 'event', 'search', 'input', query
      if query
        model.user.searchByUsername query
      else
        Rx.Observable.just []

    @$icon = new Icon()
    @$clear = new Icon()

    @$userList = new UserList {
      model, portal, users, selectedProfileDialogUser
    }

    @state = z.state
      value: @value
      users: users

  afterMount: (@$$el) =>
    @$$el.querySelector('.input').focus()

  clear: =>
    @value.onNext ''
    @$$el.querySelector('.input').focus()

  render: =>
    {value, users} = @state.getValue()

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
              @isFindFriendsVisible.onNext Rx.Observable.just false
        z 'span.right-icon',
          unless _isEmpty value
            z @$clear,
              icon: 'close'
              isAlignedTop: true
              isAlignedRight: true
              color: colors.$primary500Text
              onclick: @clear
      z 'form.form',
        onsubmit: (e) ->
          e.preventDefault()
          document.activeElement.blur() # hide keyboard
        z 'input.input',
          placeholder: 'Search by username'
          value: value
          onfocus: @open
          focused: 'focused'
          oninput: z.ev (e, $$el) =>
            @value.onNext $$el.value
      z '.results',
        z @$userList
