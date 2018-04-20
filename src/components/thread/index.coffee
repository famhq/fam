z = require 'zorium'
_map = require 'lodash/map'
_find = require 'lodash/find'
_defaults = require 'lodash/defaults'
_isEmpty = require 'lodash/isEmpty'
_flatten = require 'lodash/flatten'
_filter = require 'lodash/filter'
Environment = require '../../services/environment'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/operator/map'
require 'rxjs/add/operator/switchMap'
require 'rxjs/add/observable/of'
require 'rxjs/add/observable/combineLatest'

colors = require '../../colors'
config = require '../../config'
Base = require '../base'
AppBar = require '../app_bar'
ButtonBack = require '../button_back'
AdsenseAd = require '../adsense_ad'
Icon = require '../icon'
Avatar = require '../avatar'
ClanBadge = require '../clan_badge'
ClanMetrics = require '../clan_metrics'
ThreadComment = require '../thread_comment'
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
SCROLL_COMMENT_LOAD_COUNT = 30
TIME_UNTIL_WIGGLE_MS = 2000

module.exports = class Thread extends Base
  constructor: ({@model, @router, @overlay$, thread, @isInline, group}) ->
    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@router}

    @$clanSpinner = new Spinner()
    @$spinner = new Spinner()
    @$replyIcon = new Icon()
    @$editIcon = new Icon()
    @$pinIcon = new Icon()
    @$shareIcon = new Icon()
    @$deleteIcon = new Icon()
    @$filterIcon = new Icon()
    @$starIcon = new Icon()
    @$threadUpvoteButton = new ThreadVoteButton {@model}
    @$threadDownvoteButton = new ThreadVoteButton {@model}
    @$adsenseAd = new AdsenseAd {@model, group}

    @$fab = new Fab()
    @$avatar = new Avatar()

    @selectedProfileDialogUser = new RxBehaviorSubject false
    @$profileDialog = new ProfileDialog {
      @model, @router, @selectedProfileDialogUser, group
    }

    filter = new RxBehaviorSubject {
      sort: 'popular'
    }
    @filterAndThread = RxObservable.combineLatest(
      filter, thread, (vals...) -> vals
    ).publishReplay(1).refCount()
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

    clan = thread.switchMap (thread) =>
      if thread?.data?.extras?.clan
        @model.clan.getById thread.data?.extras?.clan.id
      else
        RxObservable.of null

    playerDeck = thread.switchMap (thread) =>
      if thread?.data?.extras?.deckId
        @model.clashRoyalePlayerDeck.getByDeckIdAndPlayerId(
          thread.data.extras.deckId
          thread.data.extras.playerId
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

    commentsAndThread = RxObservable.combineLatest(
      @commentStreams.switch()
      thread
      (vals...) -> vals
    )

    @message = new RxBehaviorSubject ''
    @isPostLoading = new RxBehaviorSubject false
    @$conversationInput = new ConversationInput {
      @model
      @router
      @message
      @overlay$
      @isPostLoading
      onPost: @postMessage
      group: group
      onResize: -> null
    }

    @state = z.state
      me: @model.user.getMe()
      selectedProfileDialogUser: @selectedProfileDialogUser
      thread: thread
      isDeckDialogVisible: false
      isCardDialogVisible: false
      hasLoadedAll: false
      group: group
      $body: new FormattedText {
        text: thread.map (thread) ->
          thread?.data?.body
        imageWidth: 'auto'
        isFullWidth: true
        embedVideos: true
        @model
        @router
      }
      $clanMetrics: clan.map (clanObj) =>
        if clanObj then new ClanMetrics {@model, @router, clan} else null
      clan: clan
      playerDeck: playerDeck
      isPostLoading: @isPostLoading
      windowSize: @model.window.getSize()
      threadComments: commentsAndThread.map ([threadComments, thread]) =>
        if threadComments?.length is 1 and threadComments[0] is null
          return null
        threadComments = _filter threadComments
        _map threadComments, (threadComment) =>
          # cache, otherwise there's a flicker on invalidate
          cacheId = "threadComment-#{threadComment.id}"
          $el = @getCached$ cacheId, ThreadComment, {
            @model, @router, @selectedProfileDialogUser, threadComment
            @commentStreams, group
          }
          # update cached version
          $el.setThreadComment threadComment
          $el

  afterMount: (@$$el) =>
    @$$content = @$$el?.querySelector '.content'
    @$$content?.addEventListener 'scroll', @scrollListener
    @$$content?.addEventListener 'resize', @scrollListener

    if @model.experiment.get('shareWiggle') is 'new'
      @wiggleTimeout = setTimeout =>
        @$$el.querySelector('.share')?.classList.toggle('wiggle')
      , TIME_UNTIL_WIGGLE_MS

  beforeUnmount: =>
    super()
    @$$content?.removeEventListener 'scroll', @scrollListener
    @$$content?.removeEventListener 'resize', @scrollListener
    clearTimeout @wiggleTimeout

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
          limit: SCROLL_COMMENT_LOAD_COUNT
          skip: skip
          sort: filter?.sort
          groupId: thread.groupId
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
    .catch =>
      @state.set
        isLoading: false

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
      .then (response) =>
        @isPostLoading.next false
        response
      .catch =>
        @isPostLoading.next false

  render: =>
    {me, thread, $body, threadComments, windowSize, playerDeck,
      selectedProfileDialogUser, clan, $clanMetrics, isLoading, group,
      isPostLoading} = @state.getValue()

    hasVotedUp = thread?.myVote?.vote is 1
    hasVotedDown = thread?.myVote?.vote is -1

    hasAdminPermission = @model.thread.hasPermission thread, me, {
      level: 'admin'
    }
    hasPinThreadPermission = @model.groupUser.hasPermission {
      group, meGroupUser: group?.meGroupUser, me
      permissions: ['pinForumThread']
    }
    hasDeleteThreadPermission = @model.groupUser.hasPermission {
      group, meGroupUser: group?.meGroupUser, me
      permissions: ['deleteForumThread']
    }

    points = if thread then thread.upvotes else 0

    isNativeApp = Environment.isNativeApp(config.GAME_KEY)

    z '.z-thread',
      z @$appBar, {
        title: ''
        $topLeftButton: if not @isInline \
                        then z @$buttonBack, {
                          color: colors.$header500Icon
                          fallbackPath: @router.get 'groupForum', {
                            groupId: group?.key or group?.id
                          }
                        }
        $topRightButton:
          z '.z-thread_top-right',
            [
              z '.share', {key: 'share'},
                z @$shareIcon,
                  icon: 'share'
                  color: colors.$header500Icon
                  hasRipple: true
                  onclick: =>
                    ga? 'send', 'event', 'thread', 'share'
                    path = @model.thread.getPath thread, group, @router
                    @model.portal.call 'share.any', {
                      text: thread.data.title
                      path: path
                      url: "https://#{config.HOST}#{path}"
                    }
              if hasAdminPermission or me?.username is 'austin'
                z @$editIcon,
                  icon: 'edit'
                  color: colors.$header500Icon
                  hasRipple: true
                  onclick: =>
                    @router.go 'groupThreadEdit', {
                      groupId: group.key or group.id
                      id: thread.id
                    }
              if hasPinThreadPermission
                z @$pinIcon,
                  icon: if thread?.data?.isPinned then 'pin-off' else 'pin'
                  color: colors.$header500Icon
                  hasRipple: true
                  onclick: =>
                    if thread?.data?.isPinned
                      @model.thread.unpinById thread.id
                    else
                      @model.thread.pinById thread.id
              if hasDeleteThreadPermission
                z @$deleteIcon,
                  icon: 'delete'
                  color: colors.$header500Icon
                  hasRipple: true
                  onclick: =>
                    if confirm 'Confirm?'
                      @model.thread.deleteById thread.id
                      .then =>
                        @router.go 'groupForum', {
                          groupId: group.key or group.id
                        }
            ]
      }
      z '.content',
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
                else if thread?.creator?.username is 'clashroyalebr'
                  'ClashRoyaleBR (Oficial)'
                else
                  @model.user.getDisplayName thread?.creator

                if thread?.creator?.flags?.isStar
                  z '.icon',
                    z @$starIcon,
                      icon: 'star-tag'
                      color: colors.$tertiary900Text
                      isTouchTarget: false
                      size: '22px'
                else if thread?.creator?.flags?.isModerator
                  z '.icon',
                    z @$starIcon,
                      icon: 'mod'
                      color: colors.$tertiary900Text
                      isTouchTarget: false
                      size: '22px'
              z 'span', innerHTML: '&nbsp;&middot;&nbsp;'
              z '.time',
                if thread?.time
                then DateService.fromNow thread.time
                else '...'
            z '.title',
              thread?.data?.title

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
              z '.g-grid',
                z '.clan-info',
                  z '.badge',
                    z @$clanBadge, {clan}
                  z '.info',
                    z '.name', clan?.data.name
                    z '.tag', "##{clan?.id}"
              $clanMetrics
          ]
        else if thread?.data?.extras?.clan?.id
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

          if Environment.isMobile() and not isNativeApp
            z '.ad',
              z @$adsenseAd, {
                slot: 'mobile320x50'
              }
          else if not Environment.isMobile()
            z '.ad',
              z @$adsenseAd, {
                slot: 'desktop728x90'
              }


        z '.comments-wrapper',

          z '.g-grid',
            z '.reply',
              @$conversationInput
            if not threadComments
              @$spinner
            else if threadComments and _isEmpty threadComments
              z '.no-comments', @model.l.get 'thread.noComments'
            else if threadComments
              z '.comments',
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
