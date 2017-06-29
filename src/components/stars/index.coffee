z = require 'zorium'
Rx = require 'rx-lite'
_isEmpty = require 'lodash/isEmpty'
_map = require 'lodash/map'
_truncate = require 'lodash/truncate'

Base = require '../base'
Avatar = require '../avatar'
Icon = require '../icon'
Spinner = require '../spinner'
FormatService = require '../../services/format'
colors = require '../../colors'

if window?
  require './index.styl'

MAX_TITLE_LENGTH = 60

module.exports = class Stars extends Base
  constructor: ({@model, @router, sort, filter}) ->
    @$spinner = new Spinner()

    me = @model.user.getMe()
    stars = @model.star.getAll({sort, filter})
    # streams = @model.stream.getAll({sort, filter})

    @state = z.state
      me: @model.user.getMe()
      stars: stars.map (stars) ->
        _map stars, (star) ->
          {
            star
            $plusIcon: new Icon()
            $avatar: new Avatar()
          }

  render: =>
    {me, stars} = @state.getValue()

    z '.z-stars',
      z 'h2.title', @model.l.get 'stars.recommended'
      z '.stars',
        if stars and _isEmpty stars
          'No stars found'
        else if stars
          _map stars, ({star, $plusIcon, $avatar}) =>
            [
              @router.link z 'a.star', {
                href: "/star/#{star.user.username}"
              },
                z '.avatar',
                  z $avatar, {user: star.user}
                z '.info',
                  z '.name', @model.user.getDisplayName star.user
                  z '.followers',
                    star.user.followerCount
                    ' '
                    @model.l.get 'general.followers'
                z '.plus-icon',
                  z $plusIcon,
                    icon: 'add-friend'
                    isTouchTarget: false
                    color: colors.$white
                    size: '24px'
            ]
        else
          @$spinner
