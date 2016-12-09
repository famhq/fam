z = require 'zorium'
Rx = require 'rx-lite'
moment = require 'moment'
colors = require '../../colors'
_map = require 'lodash/map'
_defaults = require 'lodash/defaults'
_isEmpty = require 'lodash/isEmpty'
log = require 'loga'
FloatingActionButton = require 'zorium-paper/floating_action_button'
ProfileDialog = require '../profile_dialog'

config = require '../../config'
colors = require '../../colors'
Icon = require '../icon'
Avatar = require '../avatar'
PrimaryButton = require '../primary_button'
Spinner = require '../spinner'

if window?
  require './index.styl'

module.exports = class Thread
  constructor: ({@model, @router, thread}) ->
    @$spinner = new Spinner()
    @$replyIcon = new Icon()

    @$fab = new FloatingActionButton()

    @selectedProfileDialogUser = new Rx.BehaviorSubject false
    @$profileDialog = new ProfileDialog {
      @model, @router, @selectedProfileDialogUser
    }

    @state = z.state
      me: @model.user.getMe()
      selectedProfileDialogUser: @selectedProfileDialogUser
      thread: thread.map (thread) ->
        _defaults {
          messages: _map thread.messages, (message) ->
            {message, $avatar: new Avatar()}
        }, thread

  render: =>
    {me, thread, selectedProfileDialogUser} = @state.getValue()

    z '.z-thread', [
      if thread and not _isEmpty thread.messages
        _map thread.messages, ({message, $avatar}, i) =>
          isOriginalPost = i is 0
          [
            z '.g-grid',
              z '.message', {
                className: z.classKebab {isOriginalPost}
                onclick: =>
                  @selectedProfileDialogUser.onNext _defaults {
                    chatMessageId: message.id
                  }, message.user
              },
                z '.avatar',
                  z $avatar, {user: message.user, size: '40px'}
                z '.info',
                  z '.title',
                    if isOriginalPost
                      thread.title
                    else
                      @model.user.getDisplayName message.user
                  z '.text', message.body
                  z '.message-info',
                    [
                      if isOriginalPost
                        [
                          z 'span',
                            @model.user.getDisplayName message.user
                          z 'span', innerHTML: ' &middot; '
                        ]
                      z 'span', moment(message.time).fromNowModified()
                    ]
            unless isOriginalPost
              z '.divider'
          ]
      else if thread
        z '.no-messages', 'No messages found'
      else
        @$spinner

      z '.fab',
        z @$fab,
          colors:
            c500: colors.$primary500
          $icon: z @$replyIcon, {
            icon: 'reply'
            isTouchTarget: false
            color: colors.$white
          }
          onclick: =>
            @router.go "/thread/#{thread.id}/reply"

      if selectedProfileDialogUser
        console.log 'show'
        z @$profileDialog
    ]
