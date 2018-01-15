z = require 'zorium'

colors = require '../../colors'
Icon = require '../icon'
ClanBadge = require '../clan_badge'
DeckCards = require '../deck_cards'
ThreadPreview = require '../thread_preview'
ThreadVoteButton = require '../thread_vote_button'
FormatService = require '../../services/format'
DateService = require '../../services/date'

if window?
  require './index.styl'

module.exports = class ThreadListItem
  constructor: ({@model, @router, thread, gameKey}) ->
    @$threadPreview = new ThreadPreview {@model, thread}
    @$pointsIcon = new Icon()
    @$threadUpvoteButton = new ThreadVoteButton {@model}
    @$threadDownvoteButton = new ThreadVoteButton {@model}
    @$commentsIcon = new Icon()
    @$textIcon = new Icon()
    @$starIcon = new Icon()
    @$icon = if thread.data?.extras?.clan then new ClanBadge() else null
    @$deck = if thread.playerDeck then new DeckCards {
      @model, @router, deck: thread.playerDeck.deck, cardsPerRow: 4
    }

    @isImageLoaded = @model.image.isLoaded @getImageUrl thread

    @state = z.state
      me: @model.user.getMe()
      language: @model.l.getLanguage()
      isExpanded: false
      gameKey: gameKey
      thread: thread

  afterMount: (@$$el) =>
    {thread} = @state.getValue()
    unless @isImageLoaded
      @model.image.load @getImageUrl thread
      .then =>
        # don't want to re-render entire state every time a pic loads in
        @$$el?.classList.add 'is-image-loaded'
        @isImageLoaded = true

  getImageUrl: (thread) ->
    mediaAttachment = thread.data?.attachments?[0]
    mediaSrc = mediaAttachment?.previewSrc or mediaAttachment?.src

  render: ({hasPadding} = {}) =>
    hasPadding ?= true

    {me, language, gameKey, isExpanded, thread} = @state.getValue()

    # thread ?= {data: {}, playerDeck: {}}

    mediaAttachment = thread.data?.attachments?[0]
    mediaSrc = mediaAttachment?.previewSrc or mediaAttachment?.src
    hasVotedUp = thread.myVote?.vote is 1
    hasVotedDown = thread.myVote?.vote is -1

    z 'a.z-thread-list-item', {
      key: "thread-list-item-#{thread.id}"
      href: @model.thread.getPath thread, @router
      className: z.classKebab {isExpanded, @isImageLoaded, hasPadding}
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
        if thread.data?.extras?.clan
          z '.icon',
            z @$icon, {clan: thread.data?.extras?.clan, size: '34px'}
        else if mediaSrc
          z '.image',
            style:
              backgroundImage: "url(#{mediaSrc})"
            onclick: (e) =>
              e?.stopPropagation()
              e?.preventDefault()
              ga? 'send', 'event', 'thread', 'preview', ''
              @state.set isExpanded: not isExpanded
        else if @$deck
          games = thread.playerDeck.wins +
                    thread.playerDeck.losses
          winRate = FormatService.percentage(
            thread.playerDeck.wins / games
          )
          z '.deck',
            z @$deck, {cardMarginPx: 0}
            z '.win-rate', winRate
        else
          z '.text-icon',
            z @$textIcon,
              icon: if thread.category is 'deckGuide' \
                    then 'cards'
                    else 'text'
              size: '30px'
              isTouchTarget: false
              color: colors.$white
        z '.info',
          z '.title', thread.data?.title
          z '.bottom',
            z '.author',
              z '.name', @model.user.getDisplayName thread.creator
              if thread.creator?.flags?.isStar
                z '.icon',
                  z @$starIcon,
                    icon: 'star-tag'
                    color: colors.$white
                    isTouchTarget: false
                    size: '22px'
              z '.middot',
                innerHTML: '&middot;'
              z '.time',
                if thread.time
                then DateService.fromNow thread.time
                else '...'
              z '.comments',
                thread.commentCount or 0
                z '.icon',
                  z @$commentsIcon,
                    icon: 'comment'
                    isTouchTarget: false
                    color: colors.$tertiary300
                    size: '14px'

              z '.points',
                z '.icon',
                  z @$threadUpvoteButton, {
                    vote: 'up'
                    hasVoted: hasVotedUp
                    parent:
                      id: thread.id
                      type: 'thread'
                    isTouchTarget: false
                    # ripple uses anchor tag, don't want
                    # anchor within anchor since it breaks
                    # server-side render
                    hasRipple: window?
                    color: colors.$tertiary300
                    size: '14px'
                  }

                thread.upvotes or 0

                z '.icon',
                  z @$threadDownvoteButton, {
                    vote: 'down'
                    hasVoted: hasVotedDown
                    parent:
                      id: thread.id
                      type: 'thread'
                    isTouchTarget: false
                    # ripple uses anchor tag, don't want
                    # anchor within anchor since it breaks
                    # server-side render
                    hasRipple: window?
                    color: colors.$tertiary300
                    size: '14px'
                  }
      if isExpanded
        z '.preview',
          z @$threadPreview
