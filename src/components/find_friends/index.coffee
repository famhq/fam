z = require 'zorium'
_isEmpty = require 'lodash/isEmpty'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'
require 'rxjs/add/operator/debounceTime'

UserList = require '../user_list'
TopFriends = require '../top_friends'
SearchInput = require '../search_input'
Icon = require '../icon'
colors = require '../../colors'

if window?
  require './index.styl'

SEARCH_DEBOUNCE = 300

module.exports = class FindFriends
  constructor: ({@model, @isFindFriendsVisible, selectedProfileDialogUser}) ->
    @isFindFriendsVisible ?= new RxBehaviorSubject true
    @searchValue = new RxBehaviorSubject ''

    @$searchInput = new SearchInput({@model, @searchValue})

    # TODO: add infinite scroll
    # tried comblineLatest w/ debounce stream and onscrollbottom stream,
    # couldn't get it working
    users = @searchValue.debounceTime(SEARCH_DEBOUNCE).switchMap (query) =>
      if query
        @model.user.searchByUsername query
      else
        RxObservable.of []

    @$icon = new Icon()
    @$clear = new Icon()

    @$userList = new UserList {
      @model, users, selectedProfileDialogUser
    }
    @$topFriends = new TopFriends {@model, selectedProfileDialogUser}

    @state = z.state
      searchValue: @searchValue
      users: users
      windowSize: @model.window.getSize()

  afterMount: (@$$el) =>
    @$$el.querySelector('.input').focus()

  clear: =>
    @searchValue.next ''
    @$$el.querySelector('.input').focus()

  render: ({onclick, onBack, showCurrentFriends} = {}) =>
    showCurrentFriends ?= false
    onBack ?= =>
      @isFindFriendsVisible.next RxObservable.of false

    {searchValue, users, windowSize} = @state.getValue()

    z '.z-find-friends', {
      style:
        height: "#{windowSize.height}px"
    },
      z '.search',
        z @$searchInput, {
          onBack: onBack
          alwaysShowBack: true
          placeholder: @model.l.get 'findFriends.searchPlaceholder'
        }
      z '.results',
        z '.g-grid',
          if _isEmpty users
            z 'div',
              z @$topFriends, {onclick}
          else
            z 'div',
              z @$userList, {onclick}
