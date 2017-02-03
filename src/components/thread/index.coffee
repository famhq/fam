z = require 'zorium'
Rx = require 'rx-lite'
moment = require 'moment'
FloatingActionButton = require 'zorium-paper/floating_action_button'
ProfileDialog = require '../profile_dialog'
_map = require 'lodash/map'
_defaults = require 'lodash/defaults'
_isEmpty = require 'lodash/isEmpty'

colors = require '../../colors'
Icon = require '../icon'
Avatar = require '../avatar'
ThreadComment = require '../thread_comment'
DeckCards = require '../deck_cards'
Spinner = require '../spinner'
FormattedText = require '../formatted_text'
FormatService = require '../../services/format'

if window?
  require './index.styl'

module.exports = class Thread
  constructor: ({@model, @router, thread}) ->
    @$spinner = new Spinner()
    @$replyIcon = new Icon()
    @$upvoteIcon = new Icon()
    @$downvoteIcon = new Icon()

    @$fab = new FloatingActionButton()
    @$avatar = new Avatar()

    @selectedProfileDialogUser = new Rx.BehaviorSubject false
    @$profileDialog = new ProfileDialog {
      @model, @router, @selectedProfileDialogUser
    }

    deck = thread.flatMapLatest (thread) =>
      if thread.data?.deckId
        @model.clashRoyaleDeck.getById thread.data.deckId
      else
        Rx.Observable.just null

    @$deckCards = new DeckCards {@model, @router, deck}

    @state = z.state
      me: @model.user.getMe()
      selectedProfileDialogUser: @selectedProfileDialogUser
      thread: thread
      isDeckDialogVisible: false
      isCardDialogVisible: false
      isVideoVisible: false
      $body: new FormattedText {
        text: thread.map (thread) ->
          thread.body
        @model
        @router
      }
      windowSize: @model.window.getSize()
      threadComments: thread.flatMapLatest (thread) =>
        @model.threadComment.getAllByThreadId thread.id
        .map (threadComments) =>
          _map threadComments, (threadComment) =>
            new ThreadComment {
              @model, @router, threadComment, @selectedProfileDialogUser
            }


  render: =>
    {me, thread, $body, threadComments, isVideoVisible, windowSize,
      selectedProfileDialogUser} = @state.getValue()

    videoWidth = Math.min(windowSize.width, 512)

    z '.z-thread',
      if thread?.headerImage
        z '.header',
          if isVideoVisible
            z 'iframe',
              width: videoWidth
              height: videoWidth * (9 / 16)
              src: thread.data.videoUrl
              attributes:
                frameborder: 0
                allowfullscreen: true
                webkitallowfullscreen: true
          else
            z '.header-image', {
              onclick: =>
                if thread.data.videoUrl
                  @state.set isVideoVisible: true
              style:
                backgroundImage: "url(#{thread.headerImage.versions[0].url})"
            },
              z '.play'
      z '.post',
        z '.g-grid',
          z '.author',
            z '.avatar',
              z @$avatar, {user: thread?.creator, size: '20px'}
            z '.name', @model.user.getDisplayName thread?.creator
            z 'span', innerHTML: '&nbsp;&middot;&nbsp;'
            z '.time',
              if thread?.addTime
              then moment(thread?.addTime).fromNowModified()
              else '...'
          z '.title',
            thread?.title

          if thread?.data?.deckId
            z '.deck', {
              onclick: =>
                @state.set isDeckDialogVisible: true
            },
              z @$deckCards, {cardWidth: 45}

          z '.body', $body

      z '.divider'
      z '.stats',
        z '.g-grid',
          z '.vote',
            z '.upvote',
              z @$upvoteIcon,
                icon: 'upvote'
                size: '18px'
                color: colors.$white
                onclick: =>
                  @model.thread.voteById thread.id, {vote: 'up'}
            z '.downvote',
              z @$downvoteIcon,
                icon: 'downvote'
                size: '18px'
                color: colors.$white
                onclick: =>
                  @model.thread.voteById thread.id, {vote: 'down'}
          z '.score',
            "#{FormatService.number thread?.score} points"
            z 'span', innerHTML: '&nbsp;&middot;&nbsp;'
            "#{FormatService.number thread?.commentCount} comments"
      z '.divider.no-margin-bottom'

      z '.comments',
        if threadComments and _isEmpty threadComments
          z '.no-comments', 'No comments found'
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
