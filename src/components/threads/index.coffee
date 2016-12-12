z = require 'zorium'
moment = require 'moment'
FloatingActionButton = require 'zorium-paper/floating_action_button'
_map = require 'lodash/map'
_isEmpty = require 'lodash/isEmpty'

colors = require '../../colors'
Icon = require '../icon'
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
        _map threads, (thread) ->
          {thread, $icon: new Icon()}

  render: =>
    {me, threads} = @state.getValue()

    z '.z-threads', [
      if threads and _isEmpty threads
        z '.no-threads',
          'No threads found'
      else if threads
        _map threads, ({thread, $icon}) =>
          [
            z '.g-grid',
              @router.link z 'a.thread', {
                href: "/thread/#{thread.id}/1"
              },
                z '.count', thread.messageCount or 0
                z '.info',
                  z '.title', thread.title
                  z '.text', thread.firstMessage?.text
                  z '.message-info',
                    z 'span',
                      @model.user.getDisplayName thread.firstMessage?.user
                    z 'span', innerHTML: ' &middot; '
                    z 'span', moment(thread.lastUpdateTime).fromNowModified()
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
