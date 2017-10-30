z = require 'zorium'
moment = require 'moment'
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
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/combineLatest'
require 'rxjs/add/operator/switch'
require 'rxjs/add/operator/map'

colors = require '../../colors'
Icon = require '../icon'
ClanBadge = require '../clan_badge'
DeckCards = require '../deck_cards'
ThreadPreview = require '../thread_preview'
ThreadVoteButton = require '../thread_vote_button'
Spinner = require '../spinner'
FormatService = require '../../services/format'

if window?
  require './index.styl'

SCROLL_THRESHOLD = 250
SCROLL_THREAD_LOAD_COUNT = 20
SCROLL_DEBOUNCE_MS = 50

module.exports = class Threads
  constructor: ({@model, @router, @filter, gameKey}) ->
    @$spinner = new Spinner()

    @threadStreams = new RxReplaySubject(1)
    @threadStreamCache = []
    @appendThreadStream @getTopStream()

    @debouncedScroll = _debounce @scrollListener, SCROLL_DEBOUNCE_MS

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
            $threadPreview: new ThreadPreview {@model, thread}
            $pointsIcon: new Icon()
            $threadUpvoteButton: new ThreadVoteButton {@model}
            $threadDownvoteButton: new ThreadVoteButton {@model}
            $commentsIcon: new Icon()
            $textIcon: new Icon()
            $deck: if thread.playerDeck then new DeckCards {
              @model, @router, deck: thread.playerDeck.deck, cardsPerRow: 4
            }
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

    isLite = @model.experiment.get('threads') is 'lite' and
              filter.filter isnt 'clan'
    isControl = not isLite or filter.filter is 'clan'

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
                @router.go 'userOfWeek', {gameKey}
            },
              z 'span.title', @model.l.get 'threads.userOfWeek'
              z 'div',
                ' aekan '
                "(#{@model.l.get 'threads.winner'})"
              z '.description',
                @model.l.get 'threads.learnMore'
          z '.columns',
            _map chunkedThreads, (threads) =>
              z '.column',
                _map threads, (properties) =>
                  {thread, $pointsIcon, $commentsIcon, $icon, $textIcon, $deck,
                    $threadUpvoteButton, $threadDownvoteButton,
                    $threadPreview} = properties

                  mediaAttachment = thread.attachments?[0]
                  mediaSrc = mediaAttachment?.previewSrc or mediaAttachment?.src
                  isExpanded = expandedId is thread.id
                  hasVotedUp = thread.myVote?.vote is 1
                  hasVotedDown = thread.myVote?.vote is -1

                  z 'a.thread', {
                    href: @model.thread.getPath(thread, @router)
                    className: z.classKebab {isExpanded}
                    onclick: (e) =>
                      e.preventDefault()
                      # set cache manually so we don't have to re-fetch
                      req = {
                        body:
                          id: thread.id
                          language: language
                        path: 'threads.getById'
                      }
                      @model.exoid.setDataCache req, thread
                      @router.goPath @model.thread.getPath(thread, @router)
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
                        if $deck
                          games = thread.playerDeck.wins +
                                    thread.playerDeck.losses
                          winRate = FormatService.percentage(
                            thread.playerDeck.wins / games
                          )
                          z '.deck',
                            z $deck, {cardMarginPx: 0}
                            z '.win-rate', winRate
                        else
                          z '.text-icon',
                            z $textIcon,
                              icon: if thread.category is 'deckGuide' \
                                    then 'cards'
                                    else 'text'
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
                              z '.icon',
                                z $threadUpvoteButton, {
                                  vote: 'up'
                                  hasVoted: hasVotedUp
                                  parent:
                                    id: thread.id
                                    type: 'thread'
                                  isTouchTarget: false
                                  color: colors.$tertiary300
                                  size: '14px'
                                }

                              thread.upvotes or 0

                              z '.icon',
                                z $threadDownvoteButton, {
                                  vote: 'down'
                                  hasVoted: hasVotedDown
                                  parent:
                                    id: thread.id
                                    type: 'thread'
                                  isTouchTarget: false
                                  color: colors.$tertiary300
                                  size: '14px'
                                }
                    if isExpanded
                      z '.preview',
                        z $threadPreview
          if isLoading
            z '.loading', @$spinner
      else
        @$spinner
    ]
