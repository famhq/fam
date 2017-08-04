z = require 'zorium'
moment = require 'moment'
Rx = require 'rx-lite'
_map = require 'lodash/map'
_chunk = require 'lodash/chunk'
_filter = require 'lodash/filter'
_range = require 'lodash/range'
_find = require 'lodash/find'
_orderBy = require 'lodash/orderBy'
_flatten = require 'lodash/flatten'
_isEmpty = require 'lodash/isEmpty'
_uniqBy = require 'lodash/uniqBy'
_find = require 'lodash/find'

colors = require '../../colors'
Icon = require '../icon'
ClanBadge = require '../clan_badge'
Spinner = require '../spinner'

if window?
  require './index.styl'

module.exports = class Threads
  constructor: ({@model, @router, category}) ->
    @$spinner = new Spinner()

    if category is 'clan'
      threads = Rx.Observable.combineLatest(
        @model.thread.getAll({category, sort: 'new'})
        (vals...) -> vals
      )
    else
      threads = Rx.Observable.combineLatest(
        @model.thread.getAll({category})
        @model.thread.getAll({category, sort: 'new', limit: 3})
        @model.thread.getAll({category: 'news'})
        (vals...) -> vals
      )

    @state = z.state
      me: @model.user.getMe()
      chunkedThreads: threads.map ([popularThreads, newThreads, newsThreads]) ->
        # TODO: json file with these vars, stylus uses this
        if window?.matchMedia('(min-width: 768px)').matches
          cols = 2
        else
          cols = 1

        threads = _filter popularThreads.concat(newsThreads)
        threads = _uniqBy threads, 'id'
        threads = _orderBy threads, 'score', 'desc'
        _map newThreads, (thread, i) ->
          unless _find threads, {id: thread.id}
            threads.splice (i + 1) * 2, 0, thread

        threads = _map threads, (thread) ->
          {
            thread
            $pointsIcon: new Icon()
            $commentsIcon: new Icon()
            $icon: if thread.data.clan then new ClanBadge() else null
          }
        return _map _range(cols), (colIndex) ->
          _filter threads, (thread, i) -> i % cols is colIndex

  render: =>
    {me, chunkedThreads} = @state.getValue()

    z '.z-threads', [
      if chunkedThreads and _isEmpty chunkedThreads[0]
        z '.no-threads',
          'No threads found'
      else if chunkedThreads
        z '.g-grid',
          z '.columns',
            _map chunkedThreads, (threads) =>
              z '.column',
                _map threads, (properties) =>
                  {thread, $pointsIcon, $commentsIcon, $icon} = properties
                  imageAttachment = _find thread.attachments, {type: 'image'}
                  @router.link z 'a.thread', {
                    href: "/thread/#{thread.id}"
                  },
                    if imageAttachment and thread.category isnt 'clan'
                      z '.image',
                        style:
                          backgroundImage: "url(#{imageAttachment.src})"
                    z '.content',
                      if thread.data.clan
                        z '.icon',
                          z $icon, {clan: thread.data.clan, size: '34px'}
                      z '.info',
                        z '.title', thread.title
                        z '.bottom',
                          z '.author',
                            z '.name', @model.user.getDisplayName thread.creator
                            z '.middot',
                              innerHTML: '&middot;'
                            z '.time',
                              if thread.addTime
                              then moment(thread.addTime).fromNowModified()
                              else '...'
                            z '.comments',
                              thread.commentCount or 0
                              z '.icon',
                                z $commentsIcon,
                                  icon: 'comment'
                                  isTouchTarget: false
                                  color: colors.$tertiary300
                                  size: '14px'
                            z '.points',
                              (thread.upvotes - thread.downvotes) or 0
                              z '.icon',
                                z $pointsIcon,
                                  icon: 'add-circle'
                                  isTouchTarget: false
                                  color: colors.$tertiary300
                                  size: '14px'
      else
        @$spinner
    ]
