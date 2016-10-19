z = require 'zorium'
Rx = require 'rx-lite'
moment = require 'moment'
colors = require '../../colors'
_isEmpty = require 'lodash/lang/isEmpty'
_ = require 'lodash'
log = require 'loga'
Dialog = require 'zorium-paper/dialog'
FloatingActionButton = require 'zorium-paper/floating_action_button'

config = require '../../config'
colors = require '../../colors'
Icon = require '../icon'
PrimaryButton = require '../primary_button'
Spinner = require '../spinner'

if window?
  require './index.styl'

module.exports = class Threads
  constructor: ({@model, @router}) ->
    @$spinner = new Spinner()
    @$addIcon = new Icon()

    @$fab = new FloatingActionButton()

    @state = z.state
      me: @model.user.getMe()
      threads: @model.thread.getAll().map (threads) ->
        _.map threads, (thread) ->
          {thread, $icon: new Icon()}

  render: =>
    {me, threads} = @state.getValue()

    z '.z-threads', [
      if threads and _.isEmpty threads
        z '.no-threads',
          'No threads found'
      else if threads
        _.map threads, ({thread, $icon}) =>
          [
            z '.g-grid',
              z '.thread', {
                onclick: =>
                  @router.go "/thread/#{thread.id}/1"
              },
                z '.count', thread.messageCount or 0
                z '.info',
                  z '.title', thread.title
                  z '.text', thread.firstMessage?.text
                  z '.message-info',
                    z 'span',
                      @model.user.getDisplayName thread.firstMessage?.user
                    z 'span', innerHTML: ' &middot; '
                    z 'span', moment(thread.lastUpdateTime).fromNow()
                z '.right',
                  z $icon,
                    icon: thread.platform
                    isTouchTarget: false
                    color: colors["$#{thread.platform}"]
            z '.divider'
          ]
      else
        @$spinner

      z '.fab',
        z @$fab,
          colors:
            c500: colors.$primary500
          $icon: z @$addIcon, {
            icon: 'add'
            isTouchTarget: false
            color: colors.$white
          }
          onclick: =>
            @router.go '/newThread'
    ]
