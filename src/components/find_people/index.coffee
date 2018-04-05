z = require 'zorium'
_isEmpty = require 'lodash/isEmpty'
_map = require 'lodash/map'
_defaults = require 'lodash/defaults'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'
require 'rxjs/add/observable/combineLatest'
require 'rxjs/add/operator/switchMap'

FormattedText = require '../formatted_text'
PrimaryButton = require '../primary_button'
SecondaryButton = require '../secondary_button'
Message = require '../message'
UiCard = require '../ui_card'
Icon = require '../icon'
Avatar = require '../avatar'
colors = require '../../colors'

if window?
  require './index.styl'

SEARCH_DEBOUNCE = 300

module.exports = class FindPeople
  constructor: (options) ->
    {@model, @router, group, @selectedProfileDialogUser, @overlay$} = options

    @selectedTag = new RxBehaviorSubject ''

    groupAndSelectedTag = RxObservable.combineLatest(
      group, @selectedTag, (vals...) -> vals
    )

    @$infoCard = new UiCard()
    @$newLfgButton = new PrimaryButton()

    @state = z.state
      group: group
      loadingMessageId: null
      loadingFollowId: null
      followingIds: @model.userFollower.getAllFollowingIds()
      isInfoCardVisible: not @model.cookie.get 'hidePeopleInfo'
      selectedTag: @selectedTag
      lfgs: groupAndSelectedTag.switchMap ([group, selectedTag]) =>
        @model.lfg.getAllByGroupIdAndHashtag group.id, selectedTag
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
    {lfgs, loadingMessageId, loadingFollowId, followingIds,
      isInfoCardVisible, group, selectedTag} = @state.getValue()

    if @model.group.hasGameKey group, 'fortnite'
      tags = ['ps4', 'xb1', 'pc', 'mobile']
    else
      tags = ['2c2', 'clan', 'amigo']

    z '.z-find-people',
      z '.g-grid',
        if isInfoCardVisible
          z '.info-card',
            z @$infoCard,
              $content: @model.l.get 'people.infoCardText'
              submit:
                text: @model.l.get 'installOverlay.closeButtonText'
                onclick: =>
                  @state.set isInfoCardVisible: false
                  @model.cookie.set 'hidePeopleInfo', '1'

        if @model.experiment.get('lfgNewButton') is 'big'
          z '.new-lfg',
            z @$newLfgButton,
              text: @model.l.get 'findPeople.makePost'
              onclick: =>
                @router.go 'groupNewLfg', {groupId: group?.key or group?.id}

        z '.filters',
          @model.l.get 'findPeople.filters'
          ': '
          _map tags, (tag) =>
            isSelected = tag is selectedTag
            z '.tag', {
              className: z.classKebab {isSelected}
              onclick: =>
                if isSelected
                  @selectedTag.next ''
                else
                  @selectedTag.next tag
            },
              "\##{tag}",
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
                        ga? 'send', 'event', 'lfg', 'message'
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
                      ga? 'send', 'event', 'lfg', 'follow'
                      if isFollowing
                        @model.userFollower.unfollowByUserId lfg.user?.id
                      else
                        @model.userFollower.followByUserId lfg.user?.id
                  }
            z '.divider'
          ]
