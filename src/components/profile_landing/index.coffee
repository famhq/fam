z = require 'zorium'
Rx = require 'rxjs'
_take = require 'lodash/take'
Environment = require 'clay-environment'

SecondaryButton = require '../secondary_button'
GetPlayerTagForm = require '../get_player_tag_form'
config = require '../../config'

TOP_PLAYER_COUNT = 20

if window?
  require './index.styl'

module.exports = class ProfileLanding
  constructor: ({@model, @router, gameKey}) ->
    me = @model.user.getMe()

    @$getPlayerTagForm = new GetPlayerTagForm {@model, @router}
    @$findPlayerButton = new SecondaryButton()
    @$loginButton = new SecondaryButton()

    @state = z.state
      me: me
      gameKey: gameKey

  render: =>
    {me, gameKey} = @state.getValue()

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
                @router.go 'playersSearch', {gameKey}
          z '.button',
            z @$loginButton,
              text: @model.l.get 'general.signIn'
              isFullWidth: true
              onclick: =>
                @model.signInDialog.open 'signIn'

        z '.features',
          z '.feature',
            z '.image',
              style:
                backgroundImage:
                  "url(#{config.CDN_URL}/chests/super_magical_chest.png)"
            z '.info',
              z 'h2.name', @model.l.get 'profileLanding.chestCycleTitle'
              z '.description',
                @model.l.get 'profileLanding.chestCycleDescription'

          z '.feature',
            z '.image',
              style:
                backgroundImage:
                  "url(#{config.CDN_URL}/clash_royale/arena_11.png)"
            z '.info',
              z 'h2.name', @model.l.get 'profileLanding.statsTitle'
              z '.description',
                @model.l.get 'profileLanding.statsDescription'

          z '.feature.chat-and-forum',
            z '.image',
              style:
                backgroundImage:
                  "url(#{config.CDN_URL}/clash_royale/thumbs_emote.png)"
            z '.info',
              z 'h2.name', @model.l.get 'profileLanding.chatAndForumTitle'
              z '.description',
                @model.l.get 'profileLanding.chatAndForumDescription'

        z '.terms',
          z 'p',
            @model.l.get 'profileLanding.terms2'
            z 'a', {
              href: @router.get 'policies'
            }, ' TOS'
