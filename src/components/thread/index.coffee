z = require 'zorium'
_map = require 'lodash/map'
_find = require 'lodash/find'
_defaults = require 'lodash/defaults'
_isEmpty = require 'lodash/isEmpty'
_flatten = require 'lodash/flatten'
_filter = require 'lodash/filter'
Environment = require 'clay-environment'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/operator/map'
require 'rxjs/add/operator/switchMap'
require 'rxjs/add/observable/of'


colors = require '../../colors'
config = require '../../config'
Base = require '../base'
AppBar = require '../app_bar'
ButtonBack = require '../button_back'
Icon = require '../icon'
Avatar = require '../avatar'
ClanBadge = require '../clan_badge'
ClanMetrics = require '../clan_metrics'
ThreadComment = require '../thread_comment'
ThreadPreview = require '../thread_preview'
ConversationInput = require '../conversation_input'
DeckCards = require '../deck_cards'
PlayerDeckStats = require '../player_deck_stats'
Spinner = require '../spinner'
FormattedText = require '../formatted_text'
ThreadVoteButton = require '../thread_vote_button'
FilterCommentsDialog = require '../filter_comments_dialog'
Fab = require '../fab'
ProfileDialog = require '../profile_dialog'
FormatService = require '../../services/format'
DateService = require '../../services/date'

if window?
  require './index.styl'

SCROLL_THRESHOLD = 250
SCROLL_COMMENT_LOAD_COUNT = 50

module.exports = class Thread extends Base
  constructor: ({@model, @router, @overlay$, thread, @isInline, gameKey}) ->
    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@router}

    @$clanSpinner = new Spinner()
    @$spinner = new Spinner()
    @$replyIcon = new Icon()
    @$editIcon = new Icon()
    @$deleteIcon = new Icon()
    @$filterIcon = new Icon()
    @$starIcon = new Icon()
    @$threadUpvoteButton = new ThreadVoteButton {@model}
    @$threadDownvoteButton = new ThreadVoteButton {@model}

    @$fab = new Fab()
    @$avatar = new Avatar()

    @selectedProfileDialogUser = new RxBehaviorSubject false
    @$profileDialog = new ProfileDialog {
      @model, @router, @selectedProfileDialogUser, gameKey
    }

    filter = new RxBehaviorSubject {
      sort: 'popular'
    }
    @filterAndThread = RxObservable.combineLatest(
      filter, thread, (vals...) -> vals
    ).share()
    @$filterCommentsDialog = new FilterCommentsDialog {
      @model, filter, @overlay$
    }

    @commentStreams = new RxReplaySubject(1)
    @commentStreamCache = []
    @appendCommentStream @getTopStream()

    deck = thread.switchMap (thread) =>
      if thread?.data?.deckId
        @model.clashRoyaleDeck.getById thread.data.deckId
      else
        RxObservable.of null

    @$clanBadge = new ClanBadge()
    @$threadPreview = new ThreadPreview {@model, thread}

    clan = thread.switchMap (thread) =>
      if thread?.data?.clan
        @model.clan.getById thread.data?.clan.id
      else
        RxObservable.of null

    playerDeck = thread.switchMap (thread) =>
      if thread?.data?.playerId
        @model.clashRoyalePlayerDeck.getByDeckIdAndPlayerId(
          thread.data.deckId
          thread.data.playerId
        )
        .map (playerDeck) =>
          {
            playerDeck
            $deck: new DeckCards {
              @model, @router, deck: playerDeck.deck, cardsPerRow: 8
            }
            $deckStats: new PlayerDeckStats {@model, @router, playerDeck}
          }
      else
        RxObservable.of null

    @message = new RxBehaviorSubject ''
    @isPostLoading = new RxBehaviorSubject false
    @$conversationInput = new ConversationInput {
      @model
      @router
      @message
      @overlay$
      @isPostLoading
      gameKey
      onPost: @postMessage
      onResize: -> null
    }

    @state = z.state
      me: @model.user.getMe()
      selectedProfileDialogUser: @selectedProfileDialogUser
      thread: thread
      isDeckDialogVisible: false
      isCardDialogVisible: false
      isVideoVisible: false
      hasLoadedAll: false
      gameKey: gameKey
      $body: new FormattedText {
        text: thread.map (thread) ->
          thread?.body
        imageWidth: 'auto'
        @model
        @router
      }
      $clanMetrics: clan.map (clanObj) =>
        if clanObj then new ClanMetrics {@model, @router, clan} else null
      clan: clan
      playerDeck: playerDeck
      isPostLoading: @isPostLoading
      windowSize: @model.window.getSize()
      threadComments: @commentStreams.switch().map (threadComments) =>
        if threadComments?.length is 1 and threadComments[0] is null
          return null
        threadComments = _filter threadComments
        _map threadComments, (threadComment) =>
          # cache, otherwise there's a flicker on invalidate
          cacheId = "threadComment-#{threadComment.id}"
          $el = @getCached$ cacheId, ThreadComment, {
            @model, @router, @selectedProfileDialogUser, threadComment
          }
          # update cached version
          $el.setThreadComment threadComment
          $el

  afterMount: (@$$el) =>
    @$$content = @$$el?.querySelector '.content'
    @$$content?.addEventListener 'scroll', @scrollListener
    @$$content?.addEventListener 'resize', @scrollListener

  beforeUnmount: =>
    @$$content?.removeEventListener 'scroll', @scrollListener
    @$$content?.removeEventListener 'resize', @scrollListener

  scrollListener: =>
    {isLoading, hasLoadedAll} = @state.getValue()

    if isLoading or not @$$content or hasLoadedAll
      return

    $$el = @$$content

    totalScrolled = $$el.scrollTop
    totalScrollHeight = $$el.scrollHeight - $$el.offsetHeight

    if totalScrollHeight - totalScrolled < SCROLL_THRESHOLD
      @loadMore()

  getTopStream: (skip = 0) =>
    @filterAndThread.switchMap ([filter, thread]) =>
      if thread?.id
        @model.threadComment.getAllByThreadId thread.id, {
          limit: 50
          skip: skip
          sort: filter?.sort
        }
        .map (comments) ->
          comments or false
      else
        RxObservable.of null

  loadMore: =>
    @state.set isLoading: true

    skip = @commentStreamCache.length * SCROLL_COMMENT_LOAD_COUNT
    commentStream = @getTopStream skip
    @appendCommentStream commentStream

    commentStream.take(1).toPromise()
    .then (comments) =>
      @state.set
        isLoading: false
        hasLoadedAll: _isEmpty comments

  appendCommentStream: (commentStream) =>
    @commentStreamCache = @commentStreamCache.concat [commentStream]
    @commentStreams.next \
      RxObservable.combineLatest @commentStreamCache, (comments...) ->
        _flatten comments

  postMessage: =>
    {me, isPostLoading, thread} = @state.getValue()

    if isPostLoading
      return

    messageBody = @message.getValue()
    @isPostLoading.next true

    @model.signInDialog.openIfGuest me
    .then =>
      @model.threadComment.create {
        body: messageBody
        threadId: thread.id
        parentId: thread.id
        parentType: 'thread'
      }
      .then =>
        @isPostLoading.next false
      .catch =>
        @isPostLoading.next false

  render: =>
    {me, thread, $body, threadComments, isVideoVisible, windowSize, playerDeck,
      selectedProfileDialogUser, clan, $clanMetrics, gameKey, isLoading,
      isPostLoading} = @state.getValue()

    headerAttachment = _find thread?.attachments, {type: 'video'}
    headerImageSrc = headerAttachment?.previewSrc

    videoWidth = Math.min(windowSize.width, 700)
    videoAttachment = _find thread?.attachments, {type: 'video'}

    hasVotedUp = thread?.myVote?.vote is 1
    hasVotedDown = thread?.myVote?.vote is -1

    hasAdminPermission = @model.thread.hasPermission thread, me, {
      level: 'admin'
    }

    points = if thread then thread.upvotes else 0

    z '.z-thread',
      z @$appBar, {
        title: ''
        bgColor: colors.$tertiary700
        $topLeftButton: if not @isInline \
                        then z @$buttonBack, {
                          color: colors.$primary500
                          onclick: =>
                            @router.go 'forum', {gameKey}
                        }
        $topRightButton:
          z '.z-thread_top-right',
            [
              if hasAdminPermission
                z @$editIcon,
                  icon: 'edit'
                  color: colors.$primary500
                  onclick: =>
                    @router.go 'threadEdit', {gameKey, id: thread.id}
              if me?.flags?.isModerator
                z @$deleteIcon,
                  icon: 'delete'
                  color: colors.$primary500
                  onclick: =>
                    @model.thread.deleteById thread.id
                    .then =>
                      @router.go 'forum', {gameKey}
            ]
      }
      z '.content',
        if headerImageSrc
          z '.header',
            if isVideoVisible
              z @$threadPreview, {width: videoWidth}
            else
              z '.header-image', {
                onclick: =>
                  if videoAttachment
                    @state.set isVideoVisible: true
                style:
                  backgroundImage: "url(#{headerImageSrc})"
              },
                z '.play'
        z '.post',
          z '.g-grid',
            z '.author',
              z '.avatar',
                z @$avatar, {user: thread?.creator, size: '20px'}
              z '.name', {
                onclick: =>
                  @selectedProfileDialogUser.next thread?.creator
              },
                # TODO: don't hardcode this
                if thread?.creator?.username is 'clashroyalees'
                  'ClashRoyaleES (Oficial)'
                else
                  @model.user.getDisplayName thread?.creator

                if thread?.creator?.flags?.isStar
                  z '.icon',
                    z @$starIcon,
                      icon: 'star-tag'
                      color: colors.$white
                      isTouchTarget: false
                      size: '22px'
              z 'span', innerHTML: '&nbsp;&middot;&nbsp;'
              z '.time',
                if thread?.addTime
                then DateService.fromNow thread.addTime
                else '...'
            z '.title',
              thread?.title

            if playerDeck
              z '.deck', {
                # onclick: =>
                #   @state.set isDeckDialogVisible: true
              },
                z playerDeck.$deck, {cardWidth: 45}
                z playerDeck.$deckStats

            z '.body', $body

        if clan
          [
            z '.divider'
            z '.clan',
              z '.clan-info',
                z '.badge',
                  z @$clanBadge, {clan}
                z '.info',
                  z '.name', clan?.data.name
                  z '.tag', "##{clan?.id}"
              $clanMetrics
          ]
        else if thread?.data?.clan?.id
          [
            z '.divider'
            z '.clan',
              z @$clanSpinner
          ]

        z '.divider'
        z '.stats',
          z '.g-grid',
            z '.vote',
              z '.upvote',
                z @$threadUpvoteButton, {
                  vote: 'up'
                  hasVoted: hasVotedUp
                  parent:
                    id: thread?.id
                    type: 'thread'
                }
              z '.downvote',
                z @$threadDownvoteButton, {
                  vote: 'down'
                  hasVoted: hasVotedDown
                  parent:
                    id: thread?.id
                    type: 'thread'
                }
            z '.score',
              "#{FormatService.number points} #{@model.l.get('thread.points')}"
              z 'span', innerHTML: '&nbsp;&middot;&nbsp;'
              "#{FormatService.number thread?.commentCount} "
              @model.l.get 'thread.comments'
            z '.filter-icon',
              z @$filterIcon,
                icon: 'filter'
                isTouchTarget: false
                color: colors.$tertiary900Text
                onclick: =>
                  @overlay$.next @$filterCommentsDialog

        z '.reply',
          @$conversationInput

        z '.comments',
          if not threadComments
            @$spinner
          else if threadComments and _isEmpty threadComments
            z '.no-comments', @model.l.get 'thread.noComments'
          else if threadComments
            [
              _map threadComments, ($threadComment) ->
                [
                  z $threadComment
                  z '.divider'
                ]
              if isLoading
                z '.loading', @$spinner
            ]

      if selectedProfileDialogUser
        z @$profileDialog
