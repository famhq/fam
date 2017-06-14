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
      threads: @model.thread.getAll({category: 'news'}).map (threads) ->
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
                href: "/thread/#{thread.id}"
              },
                if thread.image
                  z 'img.image',
                    src: thread.image
                z '.title', thread.title
                z '.info',
                  z '.author',
                    z '.name', @model.user.getDisplayName thread.user
                    z '.middot',
                      innerHTML: '&middot;'
                    z '.time',
                      if thread.addTime
                      then moment(thread.addTime).fromNowModified()
                      else '...'
                    z '.middot',
                      innerHTML: '&middot;'
                    z '.count',
                      thread.commentCount or 0
                      ' comments'

          ]
      else
        @$spinner

      # z '.fab',
      #   z @$fab,
      #     colors:
      #       c500: colors.$primary500
      #     $icon: z @$addIcon, {
      #       icon: 'add'
      #       isTouchTarget: false
      #       color: colors.$white
      #     }
      #     onclick: =>
      #       @router.go '/newThread'
    ]
