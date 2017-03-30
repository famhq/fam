z = require 'zorium'
moment = require 'moment'
_map = require 'lodash/map'
_isEmpty = require 'lodash/isEmpty'

colors = require '../../colors'
Icon = require '../icon'
Spinner = require '../spinner'
Fab = require '../fab'

if window?
  require './index.styl'

module.exports = class Threads
  constructor: ({@model, @router}) ->
    @$spinner = new Spinner()
    @$addIcon = new Icon()

    @$fab = new Fab()

    @state = z.state
      me: @model.user.getMe()
      threads: @model.thread.getAll().map (threads) ->
        _map threads, (thread) ->
          {
            thread
            $upvoteIcon: new Icon()
            $downvoteIcon: new Icon()
            $commentIcon: new Icon()
          }

  render: =>
    {me, threads} = @state.getValue()

    z '.z-threads', [
      if threads and _isEmpty threads
        z '.no-threads',
          'No threads found'
      else if threads
        _map threads, ({thread, $upvoteIcon, $downvoteIcon, $commentIcon}) =>
          [
            z '.g-grid',
              @router.link z 'a.thread', {
                href: "/thread/#{thread.id}/1"
              },
                z '.content',
                  z '.author',
                    z '.name', @model.user.getDisplayName thread.user
                    z '.middot',
                      innerHTML: '&middot;'
                    z '.time',
                      if thread.addTime
                      then moment(thread.addTime).fromNowModified()
                      else '...'
                  z '.title', thread.title
                  z '.text', thread.firstMessage?.text
                  z '.stats',
                    z '.votes',
                      z $upvoteIcon,
                        icon: 'upvote'
                        color: colors.$white54
                        size: '12px'
                        touchWidth: '24px'
                        touchHeight: '24px'
                        onclick: =>
                          @vote thread.id, 'up'
                      z '.count', thread.score or 0
                      z $downvoteIcon,
                        icon: 'downvote'
                        color: colors.$white54
                        size: '12px'
                        touchWidth: '24px'
                        touchHeight: '24px'
                        onclick: =>
                          @vote thread.id, 'down'
                    z '.comments',
                      z $commentIcon,
                        icon: 'comment'
                        color: colors.$white54
                        size: '12px'
                        touchWidth: '24px'
                        touchHeight: '24px'
                      z '.count', thread.commentCount or 0


                if thread.image
                  z '.right',
                    z 'img.image',
                      src: thread.image
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
