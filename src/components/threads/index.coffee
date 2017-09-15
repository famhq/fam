z = require 'zorium'
moment = require 'moment'
Rx = require 'rx-lite'
_map = require 'lodash/map'
_chunk = require 'lodash/chunk'
_filter = require 'lodash/filter'
_range = require 'lodash/range'
_debounce = require 'lodash/debounce'
_find = require 'lodash/find'
_orderBy = require 'lodash/orderBy'
_flatten = require 'lodash/flatten'
_isEmpty = require 'lodash/isEmpty'
_uniqBy = require 'lodash/uniqBy'
_find = require 'lodash/find'

colors = require '../../colors'
Icon = require '../icon'
ClanBadge = require '../clan_badge'
ThreadPreview = require '../thread_preview'
Spinner = require '../spinner'

if window?
  require './index.styl'

SCROLL_THRESHOLD = 250
SCROLL_THREAD_LOAD_COUNT = 20
SCROLL_DEBOUNCE_MS = 50

module.exports = class Threads
  constructor: ({@model, @router, @category, @sort}) ->
    @$spinner = new Spinner()

    @threadStreams = new Rx.ReplaySubject(1)
    @threadStreamCache = []
    @appendThreadStream @getTopStream()

    @debouncedScroll = _debounce @scrollListener, SCROLL_DEBOUNCE_MS

    @state = z.state
      me: @model.user.getMe()
      language: @model.l.getLanguage()
      category: @category
      expandedId: null
      isLoading: false
      chunkedThreads: @threadStreams.switch().map (threads) =>
        # TODO: json file with these vars, stylus uses this
        if window?.matchMedia('(min-width: 768px)').matches
          cols = 2
        else
          cols = 1

        threads = _map threads, (thread) =>
          {
            thread
            $threadPreview: new ThreadPreview {@model, thread}
            $pointsIcon: new Icon()
            $commentsIcon: new Icon()
            $textIcon: new Icon()
            $icon: if thread.data.clan then new ClanBadge() else null
          }
        return _map _range(cols), (colIndex) ->
          _filter threads, (thread, i) -> i % cols is colIndex

  afterMount: (@$$el) =>
    @$$el?.addEventListener 'scroll', @debouncedScroll
    @$$el?.addEventListener 'resize', @debouncedScroll

  beforeUnmount: =>
    @$$el?.removeEventListener 'scroll', @debouncedScroll
    @$$el?.removeEventListener 'resize', @debouncedScroll

  scrollListener: =>
    {isLoading} = @state.getValue()

    if isLoading
      return

    $$el = @$$el

    totalScrolled = $$el.scrollTop
    totalScrollHeight = $$el.scrollHeight - $$el.offsetHeight

    if totalScrollHeight - totalScrolled < SCROLL_THRESHOLD
      @loadMore()

  getTopStream: (skip = 0) =>
    @model.thread.getAll {
      @category
      @sort
      skip
      limit: SCROLL_THREAD_LOAD_COUNT
    }

  loadMore: =>
    @state.set
      isLoading: true

    skip = @threadStreamCache.length * SCROLL_THREAD_LOAD_COUNT
    threadStream = @getTopStream skip
    @appendThreadStream threadStream

    threadStream.take(1).toPromise()
    .then =>
      @state.set
        isLoading: false

  appendThreadStream: (threadStream) =>
    @threadStreamCache = @threadStreamCache.concat [threadStream]
    @threadStreams.onNext \
      Rx.Observable.combineLatest @threadStreamCache, (threads...) ->
        _flatten threads

  render: =>
    {me, chunkedThreads, language, category,
      expandedId, isLoading} = @state.getValue()

    isLite = @model.experiment.get('threads') is 'lite' and category isnt 'clan'
    isControl = not isLite or category is 'clan'

    z '.z-threads', {
      className: z.classKebab {isLite, isControl}
    }, [
      if chunkedThreads and _isEmpty chunkedThreads[0]
        z '.no-threads',
          'No threads found'
      else if chunkedThreads
        z '.g-grid',
          if language is 'es'
            z '.user-of-week', {
              onclick: =>
                @router.go '/user-of-week'
            },
              z 'span.title', @model.l.get 'threads.userOfWeek'
              ' Austin '
              "(#{@model.l.get 'threads.winner'})"
              z '.description',
                @model.l.get 'threads.learnMore'
          z '.columns',
            _map chunkedThreads, (threads) =>
              z '.column',
                _map threads, (properties) =>
                  {thread, $pointsIcon, $commentsIcon, $icon, $textIcon,
                    $threadPreview} = properties

                  mediaAttachment = thread.attachments?[0]
                  mediaSrc = mediaAttachment?.previewSrc or mediaAttachment?.src
                  isExpanded = expandedId is thread.id

                  @router.link z 'a.thread', {
                    href: "/thread/#{thread.id}"
                    className: z.classKebab {isExpanded}
                  },
                    z '.content',
                      if thread.data.clan
                        z '.icon',
                          z $icon, {clan: thread.data.clan, size: '34px'}
                      else if mediaSrc
                        z '.image',
                          style:
                            backgroundImage: "url(#{mediaSrc})"
                          onclick: (e) =>
                            unless isLite
                              return
                            e?.stopPropagation()
                            e?.preventDefault()
                            ga? 'send', 'event', 'thread', 'preview', ''
                            @state.set expandedId: if expandedId is thread.id \
                                                   then null
                                                   else thread.id
                      else if isLite
                        z '.text-icon',
                          z $textIcon,
                            icon: 'text'
                            size: '30px'
                            isTouchTarget: false
                            color: colors.$white
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
                              thread.upvotes or 0
                              z '.icon',
                                z $pointsIcon,
                                  icon: 'add-circle'
                                  isTouchTarget: false
                                  color: colors.$tertiary300
                                  size: '14px'
                    if isExpanded
                      z '.preview',
                        z $threadPreview
          if isLoading
            z '.loading', @$spinner
      else
        @$spinner
    ]
