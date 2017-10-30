z = require 'zorium'

SecondaryButton = require '../secondary_button'
VerifyAccountDialog = require '../verify_account_dialog'
Dialog = require '../dialog'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class AutoRefreshDialog
  constructor: ({@model, @router, @overlay$, gameKey}) ->
    @$dialog = new Dialog()
    @$verifyAccountButton = new SecondaryButton()
    @$visitForumButton = new SecondaryButton()
    @$verifyAccountDialog = new VerifyAccountDialog {@model, @router, @overlay$}

    @state = z.state
      gameKey: gameKey
      mePlayer: @model.user.getMe().switchMap ({id}) =>
        @model.player.getByUserIdAndGameId id, config.CLASH_ROYALE_ID

  render: =>
    {gameKey, mePlayer} = @state.getValue()

    z '.z-auto-refresh-dialog',
      z @$dialog,
        isVanilla: true
        isWide: true
        onLeave: =>
          @overlay$.next null
        $title: @model.l.get 'profileInfo.autoRefresh'
        $content:
          z '.z-auto-refresh-dialog_dialog',
            z 'p', @model.l.get 'profileInfo.autoRefreshText1'
            z 'p.subhead', @model.l.get 'profileInfo.autoRefreshText2'
            z '.step',
              z '.number', '1'
              z '.info', @model.l.get 'profileInfo.autoRefreshVerifyAccount'

            if mePlayer and not mePlayer?.isVerified
              z '.verify-button',
                z @$verifyAccountButton,
                  text: @model.l.get 'clanInfo.verifySelf'
                  onclick: =>
                    @overlay$.next @$verifyAccountDialog
            z '.step',
              z '.number', '2'
              z '.info', @model.l.get 'profileInfo.autoRefreshVisitForum'
            z '.visit-forum-button',
              z @$visitForumButton,
                text: @model.l.get 'general.forum'
                onclick: =>
                  @overlay$.next null
                  @router.go 'forum', {gameKey}

            z 'div', @model.l.get 'profileInfo.autoRefreshVisitForumDescription'
        cancelButton:
          text: @model.l.get 'installOverlay.closeButtonText'
          onclick: =>
            @overlay$.next null
