z = require 'zorium'
_take = require 'lodash/take'
_map = require 'lodash/map'

Avatar = require '../avatar'
Icon = require '../icon'
SecondaryButton = require '../secondary_button'
Spinner = require '../spinner'
FormatService = require '../../services/format'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ProfileInfo
  constructor: ({@model, @router, user, gameKey}) ->
    @$avatar = new Avatar()
    @$fireIcon = new Icon()
    @$setAvatarButton = new SecondaryButton()
    @$setUsernameButton = new SecondaryButton()
    @$messageButton = new SecondaryButton()
    @$followButton = new SecondaryButton()
    @$spinner = new Spinner()

    @state = z.state
      user: user.map (user) -> user or false
      gameKey: gameKey
      followingIds: @model.userFollower.getAllFollowingIds()
      groups: user.switchMap (user) =>
        @model.group.getAllByUserId user.id, {embed: []}
      me: @model.user.getMe()

  render: ({isOtherProfile} = {}) =>
    {me, user, gameKey, followingIds, groups} = @state.getValue()

    isMe = user?.id and user?.id is me?.id
    isFollowing = followingIds and followingIds.indexOf(user?.id) isnt -1

    groupStr = _map(_take(groups, 2), 'name').join ', '
    if groups?.length > 2
      groupStr += ", +#{groups.length - 2}"

    z '.z-profile-info',
      if not user and user isnt false
        @$spinner
      else
        [
          z '.avatar',
            z @$avatar,
              user: user
              size: '60px'
          z '.info',
            z '.name',
              @model.user.getDisplayName user
            z '.groups',
              groupStr
            z '.fire',
              FormatService.number user?.fire
              z '.icon',
                z @$fireIcon,
                  icon: 'fire'
                  isTouchTarget: false
                  color: colors.$quaternary500
                  size: '16px'
          z '.actions',
            if isMe
              [
                unless user?.avatarImage
                  z '.set-avatar',
                    z @$setAvatarButton,
                      text: @model.l.get 'editProfile.avatarButtonText'
                      heightPx: 26
                      onclick: =>
                        @router.go 'editProfile', {gameKey}
                unless user?.username
                  z '.set-username',
                    z @$setUsernameButton,
                      text: @model.l.get 'profileInfo.setUsername'
                      heightPx: 26
                      onclick: =>
                        @router.go 'editProfile', {gameKey}
              ]
            else if not isMe
              [
                z '.follow-button',
                  z @$followButton,
                    heightPx: 26
                    text: if isFollowing \
                      then @model.l.get 'profileInfo.followButtonIsFollowingText'
                      else @model.l.get 'profileInfo.followButtonText'
                    onclick: =>
                      if isFollowing
                        @model.userFollower.unfollowByUserId user?.id
                      else
                        @model.userFollower.followByUserId user?.id
                if user and not user?.flags?.isStar
                  z '.message-button',
                    z @$messageButton,
                      text: @model.l.get 'profileDialog.message'
                      heightPx: 26
                      onclick: =>
                        # TODO: loading msg
                        @model.conversation.create {
                          userIds: [user.id]
                        }
                        .then ({id}) =>
                          @router.go 'conversation', {gameKey, id}
              ]
        ]
