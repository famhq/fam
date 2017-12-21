z = require 'zorium'
_map = require 'lodash/map'
_chunk = require 'lodash/chunk'
_filter = require 'lodash/filter'
_range = require 'lodash/range'
_find = require 'lodash/find'
_orderBy = require 'lodash/orderBy'
_flatten = require 'lodash/flatten'
_isEmpty = require 'lodash/isEmpty'
_uniqBy = require 'lodash/uniqBy'
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/combineLatest'
require 'rxjs/add/operator/switch'
require 'rxjs/add/operator/map'

colors = require '../../colors'
ThreadListItem = require '../thread_list_item'
Spinner = require '../spinner'

if window?
  require './index.styl'

SCROLL_THRESHOLD = 250
SCROLL_THREAD_LOAD_COUNT = 20

module.exports = class Threads
  constructor: ({@model, @router, @filter, gameKey}) ->
    @$spinner = new Spinner()

    @threadStreams = new RxReplaySubject(1)
    @threadStreamCache = []
    @appendThreadStream @getTopStream()

    @state = z.state
      me: @model.user.getMe()
      language: @model.l.getLanguage()
      filter: @filter
      expandedId: null
      isLoading: false
      gameKey: gameKey
      chunkedThreads: @threadStreams.switch().map (threads) =>
        # TODO: json file with these vars, stylus uses this
        if window?.matchMedia('(min-width: 768px)').matches
          cols = 2
        else
          cols = 1

        threads = _map threads, (thread) =>
          {
            thread
            $threadListItem: new ThreadListItem {
              @model, @router, gameKey, thread
            }
          }
        return _map _range(cols), (colIndex) ->
          _filter threads, (thread, i) -> i % cols is colIndex

  afterMount: (@$$el) =>
    @$$el?.addEventListener 'scroll', @scrollListener
    @$$el?.addEventListener 'resize', @scrollListener

  beforeUnmount: =>
    @$$el?.removeEventListener 'scroll', @scrollListener
    @$$el?.removeEventListener 'resize', @scrollListener

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
    @filter.switchMap (filter) =>
      @model.thread.getAll {
        categories: [filter.filter]
        sort: filter.sort
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
    @threadStreams.next \
      RxObservable.combineLatest @threadStreamCache, (threads...) ->
        _flatten threads

  render: =>
    {me, chunkedThreads, language, filter, gameKey,
      expandedId, isLoading} = @state.getValue()

    # isLite = @model.experiment.get('threads') is 'lite' and
    #           filter.filter isnt 'clan'
    # isControl = not isLite or filter.filter is 'clan'
    isLite = true

    z '.z-threads', {
      className: z.classKebab {isLite}#, isControl}
    }, [
      if chunkedThreads and _isEmpty chunkedThreads[0]
        z '.no-threads',
          'No threads found'
      else if chunkedThreads
        z '.g-grid',
          # if language is 'es'
          #   z '.user-of-week', {
          #     onclick: =>
          #       @router.go 'userOfWeek', {gameKey}
          #   },
          #     z 'span.title', @model.l.get 'threads.userOfWeek'
          #     z 'div',
          #       ' vegetaariel '
          #       "(#{@model.l.get 'threads.winner'})"
          #     z '.description',
          #       @model.l.get 'threads.learnMore'
          z '.columns',
            _map chunkedThreads, (threads) ->
              z '.column',
                _map threads, ({$threadListItem}) ->
                  $threadListItem
          if isLoading
            z '.loading', @$spinner
      else
        @$spinner
    ]
