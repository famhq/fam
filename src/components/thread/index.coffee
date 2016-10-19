_ = require 'lodash'
z = require 'zorium'
Rx = require 'rx-lite'
moment = require 'moment'
colors = require '../../colors'
_isEmpty = require 'lodash/lang/isEmpty'
log = require 'loga'
Dialog = require 'zorium-paper/dialog'
FloatingActionButton = require 'zorium-paper/floating_action_button'

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

    @state = z.state
      me: @model.user.getMe()
      thread: thread.map (thread) ->
        _.defaults {
          messages: _.map thread.messages, (message) ->
            {message, $avatar: new Avatar()}
        }, thread

  render: =>
    {me, thread} = @state.getValue()

    z '.z-thread', [
      if thread
        _.map thread.messages, ({message, $avatar}, i) =>
          isOriginalPost = i is 0
          [
            z '.g-grid',
              z '.message', {
                className: z.classKebab {isOriginalPost}
                onclick: -> null
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
                      z 'span', moment(message.time).fromNow()
                    ]
            unless isOriginalPost
              z '.divider'
          ]
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
    ]
