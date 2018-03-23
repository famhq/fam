z = require 'zorium'
_isEmpty = require 'lodash/isEmpty'
_map = require 'lodash/map'
_defaults = require 'lodash/defaults'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'
require 'rxjs/add/operator/switchMap'

FormattedText = require '../formatted_text'
SecondaryButton = require '../secondary_button'
Message = require '../message'
Icon = require '../icon'
Avatar = require '../avatar'
colors = require '../../colors'

if window?
  require './index.styl'

SEARCH_DEBOUNCE = 300

module.exports = class FindPeople
  constructor: (options) ->
    {@model, @router, group, @selectedProfileDialogUser, @overlay$} = options

    @state = z.state
      group: group
      loadingMessageId: null
      loadingFollowId: null
      followingIds: @model.userFollower.getAllFollowingIds()
      lfgs: group.switchMap (group) =>
        @model.lfg.getAllByGroupId group.id
        .map (lfgs) =>
          _map lfgs, (lfg) =>
            $body = new FormattedText {
              @model, @router, text: lfg.text, @selectedProfileDialogUser
            }
            $message = new Message {
              message: lfg
              $body
              isMe: lfg.userId is me?.id # FIXME
              @model
              @overlay$
              @selectedProfileDialogUser
              @router
              # @messageBatchesStreams
            }
            {
              $message
              lfg
              $messageButton: new SecondaryButton()
              $followButton: new SecondaryButton()
            }

  openProfileDialog: (id, user, groupUser) =>
    @selectedProfileDialogUser.next _defaults {
      groupUser: groupUser
      onDeleteMessage: =>
        {group} = @state.getValue()
        @model.lfg.deleteByGroupIdAndUserId group.id, user.id
    }, user

  render: =>
    {lfgs, loadingMessageId, loadingFollowId, followingIds} = @state.getValue()

    z '.z-find-people',
      z '.g-grid',
        _map lfgs, ({$message, $messageButton, $followButton, lfg}) =>
          isFollowing = followingIds and
                          followingIds.indexOf(lfg.user?.id) isnt -1
          [
            z '.lfg',
              z $message, {
                openProfileDialogFn: @openProfileDialog
              }
              z '.actions',
                z '.action',
                  z $messageButton, {
                    text: @model.l.get 'profileDialog.message'
                    heightPx: 26
                    onclick: =>
                      @state.set loadingMessageId: lfg.id
                      @model.conversation.create {
                        userIds: [lfg.userId]
                      }
                      .then (conversation) =>
                        @state.set loadingMessageId: null
                        @router.go 'conversation', {id: conversation.id}
                  }
                z '.action',
                  z $followButton, {
                    text: if loadingFollowId is lfg.id \
                    then @model.l.get 'general.loading'
                    else if isFollowing
                    then @model.l.get 'profileInfo.followButtonIsFollowingText'
                    else @model.l.get 'profileInfo.followButtonText'

                    heightPx: 26
                    onclick: =>
                      if isFollowing
                        @model.userFollower.unfollowByUserId lfg.user?.id
                      else
                        @model.userFollower.followByUserId lfg.user?.id
                  }
            z '.divider'
          ]
