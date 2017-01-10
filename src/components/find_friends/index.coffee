z = require 'zorium'
Rx = require 'rx-lite'
_isEmpty = require 'lodash/isEmpty'

UserList = require '../user_list'
TopFriends = require '../top_friends'
SearchInput = require '../search_input'
Icon = require '../icon'
colors = require '../../colors'

if window?
  require './index.styl'

SEARCH_DEBOUNCE = 300

module.exports = class FindFriends
  constructor: ({model, @isFindFriendsVisible, selectedProfileDialogUser}) ->
    @isFindFriendsVisible ?= new Rx.BehaviorSubject true
    @searchValue = new Rx.BehaviorSubject ''

    @$searchInput = new SearchInput({@searchValue})

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
      windowSize: model.window.getSize()

  afterMount: (@$$el) =>
    @$$el.querySelector('.input').focus()

  clear: =>
    @searchValue.onNext ''
    @$$el.querySelector('.input').focus()

  render: ({onclick, onBack, showCurrentFriends} = {}) =>
    showCurrentFriends ?= false
    onBack ?= =>
      @isFindFriendsVisible.onNext Rx.Observable.just false

    {searchValue, users, windowSize} = @state.getValue()

    z '.z-find-friends', {
      style:
        height: "#{windowSize.height}px"
    },
      z '.search',
        z @$searchInput, {
          onBack: onBack
          placeholder: 'Search by username'
        }
      z '.results',
        z '.g-grid',
          if _isEmpty users
            z 'div',
              z @$topFriends, {onclick}
          else
            z 'div',
              z @$userList, {onclick}
