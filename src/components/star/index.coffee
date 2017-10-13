z = require 'zorium'

Avatar = require '../avatar'
GroupHeader = require '../group_header'
PrimaryButton = require '../primary_button'
SecondaryButton = require '../secondary_button'
Icon = require '../icon'
FormatService = require '../../services/format'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class Star
  constructor: ({@model, @router, star, @isDonateDialogVisible}) ->
    group = star.map (star) -> star?.group
    @$groupHeader = new GroupHeader {@model, @router, group}
    @$avatar = new Avatar()
    @$verifiedIcon = new Icon()

    @$donateButton = new PrimaryButton()

    @state = z.state
      star: star

  render: =>
    {star} = @state.getValue()

    z '.z-star',
      z '.g-grid',
        @$groupHeader
        z '.info',
          z '.avatar',
            z @$avatar, {user: star?.user}
          z '.details',
            z '.name',
              @model.user.getDisplayName star?.user
            z '.status',
              z '.icon',
                z @$verifiedIcon,
                  icon: 'verified'
                  color: colors.$secondary500
                  isTouchTarget: false
                  size: '14px'
              z 'div',
                'Verified'
                z 'span', innerHTML: ' &middot; '
                FormatService.number star?.user.followerCount
                ' '
                @model.l.get 'general.followers'
        z '.buttons',
          z @$donateButton,
            text: @model.l.get 'general.donate'
            onclick: =>
              @isDonateDialogVisible.next true

      z '.divider'

      # z '.g-grid',
      #   z '.title', @model.l.get 'videos.recentVideos'
