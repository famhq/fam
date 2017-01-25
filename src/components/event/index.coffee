z = require 'zorium'
Rx = require 'rx-lite'
_filter = require 'lodash/filter'

Tabs = require '../tabs'
Icon = require '../icon'
EventInfo = require '../event_info'
EventMembers = require '../event_members'
Conversation = require '../conversation'
ProfileDialog = require '../profile_dialog'
PrimaryButton = require '../primary_button'
Spinner = require '../spinner'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class Event
  constructor: ({@model, @router, event}) ->
    @overlay$ = new Rx.BehaviorSubject null
    selectedProfileDialogUser = new Rx.BehaviorSubject null

    @$info = new EventInfo {@model, event}
    @$members = new EventMembers {@model, event, selectedProfileDialogUser}
    @$spinner = new Spinner()
    @$conversation = new Conversation {
      @model
      @router
      conversation: event.flatMapLatest (event) =>
        @model.conversation.getById event.conversationId
      @overlay$
      selectedProfileDialogUser
      scrollYOnly: true
    }
    @$infoIcon = new Icon()
    @$membersIcon = new Icon()
    @$chatIcon = new Icon()
    @$joinButton = new PrimaryButton()
    @$profileDialog = new ProfileDialog {
      @model
      @router
      selectedProfileDialogUser: selectedProfileDialogUser
    }
    @$tabs = new Tabs {@model}

    @state = z.state
      overlay$: @overlay$
      selectedProfileDialogUser: selectedProfileDialogUser
      isJoinLoading: false
      event: event
      me: @model.user.getMe()

  join: =>
    {event, isJoinLoading, me} = @state.getValue()
    unless isJoinLoading
      @model.signInDialog.openIfGuest me
      .then =>
        @state.set isJoinLoading: true
        @model.event.joinById event.id
        .then =>
          @state.set isJoinLoading: false

  render: =>
    {overlay$, isJoinLoading, selectedProfileDialogUser, me,
      event} = @state.getValue()

    isFull = event?.userIds.length >= event?.maxUserCount
    hasMemberPermission = @model.event.hasPermission event, me, {
      level: 'member'
    }

    z '.z-event',
      if event and me
        [
          z @$tabs,
            isBarFixed: false
            fitToParent: true
            barBgColor: colors.$tertiary700
            barInactiveColor: colors.$white
            tabs: _filter [
              {
                $menuIcon: @$infoIcon
                menuIconName: 'info'
                $menuText: 'Info'
                $el: @$info
              }
              {
                $menuIcon: @$membersIcon
                menuIconName: 'friends'
                $menuText: 'Members'
                $el: @$members
              }
              if hasMemberPermission
                {
                  $menuIcon: @$chatIcon
                  menuIconName: 'hashtag'
                  $menuText: 'Chat'
                  $el: @$conversation
                }
            ]

          if not hasMemberPermission and not isFull
            z '.join',
              z '.g-grid',
                z @$joinButton,
                  text: if isJoinLoading then 'Loading...' else 'Join event'
                  onclick: @join
        ]
      else
        @$spinner
      overlay$
      if selectedProfileDialogUser
        @$profileDialog
