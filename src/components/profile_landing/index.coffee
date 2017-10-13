z = require 'zorium'
Rx = require 'rx-lite'
_take = require 'lodash/take'
Environment = require 'clay-environment'

SecondaryButton = require '../secondary_button'
GetPlayerTagForm = require '../get_player_tag_form'
PlayerList = require '../player_list'
config = require '../../config'

TOP_PLAYER_COUNT = 20

if window?
  require './index.styl'

module.exports = class ProfileLanding
  constructor: ({@model, @router}) ->
    me = @model.user.getMe()

    @$getPlayerTagForm = new GetPlayerTagForm {@model, @router}
    @$findPlayerButton = new SecondaryButton()
    @$loginButton = new SecondaryButton()

    @$playerList = new PlayerList {
      @model
      @router
      @selectedProfileDialogUser
      players: @model.player.getTop().map (players) ->
        _take players, TOP_PLAYER_COUNT
    }

    @state = z.state
      me: me

  render: =>
    {me} = @state.getValue()

    z '.z-profile-landing',
      z '.header-background'
      z '.content',
        z '.g-grid',
          z '.header',
            z '.title',
              @model.l.get 'profileLanding.title'
            z '.description',
              @model.l.get 'profileLanding.description'
            z '.form',
              z @$getPlayerTagForm

      z '.g-grid',
        z '.actions',
          z '.button',
            z @$findPlayerButton,
              text: @model.l.get 'playersSearch.trackButtonText'
              isFullWidth: true
              onclick: =>
                @router.go '/players/search'
          z '.button',
            z @$loginButton,
              text: @model.l.get 'general.signIn'
              isFullWidth: true
              onclick: =>
                @model.signInDialog.open 'signIn'

        # TODO: replace with info about starfire
        z '.subhead', @model.l.get 'playersPage.playersTop'
        z @$playerList, {
          onclick: ({player}) =>
            userId = player?.userId
            @router.go "/user/id/#{userId}"
        }

        z '.terms',
          z 'p',
            @model.l.get 'profileLanding.terms2'
            z 'a', {
              href: '/policies'
            }, ' TOS'
