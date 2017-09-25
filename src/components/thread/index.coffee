z = require 'zorium'
Rx = require 'rx-lite'
moment = require 'moment'
_map = require 'lodash/map'
_find = require 'lodash/find'
_defaults = require 'lodash/defaults'
_isEmpty = require 'lodash/isEmpty'
Environment = require 'clay-environment'

colors = require '../../colors'
config = require '../../config'
AppBar = require '../app_bar'
ButtonBack = require '../button_back'
Icon = require '../icon'
Avatar = require '../avatar'
ClanBadge = require '../clan_badge'
ClanMetrics = require '../clan_metrics'
ThreadComment = require '../thread_comment'
ThreadPreview = require '../thread_preview'
DeckCards = require '../deck_cards'
PlayerDeckStats = require '../player_deck_stats'
Spinner = require '../spinner'
FormattedText = require '../formatted_text'
ThreadVoteButton = require '../thread_vote_button'
Fab = require '../fab'
ProfileDialog = require '../profile_dialog'
FormatService = require '../../services/format'

if window?
  require './index.styl'

module.exports = class Thread
  constructor: ({@model, @router, thread, @isInline}) ->
    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@router}

    @$clanSpinner = new Spinner()
    @$spinner = new Spinner()
    @$replyIcon = new Icon()
    @$editIcon = new Icon()
    @$deleteIcon = new Icon()
    @$threadUpvoteButton = new ThreadVoteButton {@model}
    @$threadDownvoteButton = new ThreadVoteButton {@model}

    @$fab = new Fab()
    @$avatar = new Avatar()

    @selectedProfileDialogUser = new Rx.BehaviorSubject false
    @$profileDialog = new ProfileDialog {
      @model, @router, @selectedProfileDialogUser
    }

    deck = thread.flatMapLatest (thread) =>
      if thread?.data?.deckId
        @model.clashRoyaleDeck.getById thread.data.deckId
      else
        Rx.Observable.just null

    @$clanBadge = new ClanBadge()
    @$threadPreview = new ThreadPreview {@model, thread}

    clan = thread.flatMapLatest (thread) =>
      if thread?.data?.clan
        @model.clan.getById thread.data?.clan.id
      else
        Rx.Observable.just null

    playerDeck = thread.flatMapLatest (thread) =>
      if thread?.data?.playerDeckId
        @model.clashRoyalePlayerDeck.getById thread.data.playerDeckId
        .map (playerDeck) =>
          {
            playerDeck
            $deck: new DeckCards {
              @model, @router, deck: playerDeck.deck, cardsPerRow: 8
            }
            $deckStats: new PlayerDeckStats {@model, @router, playerDeck}
          }
      else
        Rx.Observable.just null

    @state = z.state
      me: @model.user.getMe()
      selectedProfileDialogUser: @selectedProfileDialogUser
      thread: thread
      isDeckDialogVisible: false
      isCardDialogVisible: false
      isVideoVisible: false
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
      windowSize: @model.window.getSize()
      threadComments: thread.flatMapLatest (thread) =>
        if thread?.id
          @model.threadComment.getAllByParentIdAndParentType {
            parentId: thread.id
            parentType: 'thread'
          }
          .map (threadComments) =>
            _map threadComments, (threadComment) =>
              new ThreadComment {
                @model, @router, threadComment, @selectedProfileDialogUser
              }
        else
          Rx.Observable.just null


  render: =>
    {me, thread, $body, threadComments, isVideoVisible, windowSize, playerDeck,
      selectedProfileDialogUser, clan, $clanMetrics} = @state.getValue()

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
                            @router.go '/forum'
                        }
        $topRightButton:
          z '.z-thread_top-right',
            [
              if hasAdminPermission
                z @$editIcon,
                  icon: 'edit'
                  color: colors.$primary500
                  onclick: =>
                    @router.go "/thread/#{thread.id}/edit"
              if me?.flags?.isModerator
                z @$deleteIcon,
                  icon: 'delete'
                  color: colors.$primary500
                  onclick: =>
                    @model.thread.deleteById thread.id
                    .then =>
                      @router.go '/social'
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
                  @selectedProfileDialogUser.onNext thread?.creator
              },
                @model.user.getDisplayName thread?.creator
              z 'span', innerHTML: '&nbsp;&middot;&nbsp;'
              z '.time',
                if thread?.addTime
                then moment(thread?.addTime).fromNowModified()
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
                  vote: 'up', hasVoted: hasVotedUp, threadId: thread?.id
                }
              z '.downvote',
                z @$threadDownvoteButton, {
                  vote: 'down', hasVoted: hasVotedDown, threadId: thread?.id
                }
            z '.score',
              "#{FormatService.number points} #{@model.l.get('thread.points')}"
              z 'span', innerHTML: '&nbsp;&middot;&nbsp;'
              "#{FormatService.number thread?.commentCount} "
              @model.l.get 'thread.comments'

        z '.comments',
          if threadComments and _isEmpty threadComments
            z '.no-comments', @model.l.get 'thread.noComments'
          else if threadComments
            _map threadComments, ($threadComment) ->
              [
                z $threadComment
                z '.divider'
              ]
          else
            @$spinner

      z '.fab',
        z @$fab,
          colors:
            c500: colors.$primary500
          $icon: z @$replyIcon, {
            icon: 'reply'
            isTouchTarget: false
            color: colors.$white
          }
          onclick: =>
            @router.go "/thread/#{thread.id}/reply"

      if selectedProfileDialogUser
        z @$profileDialog
