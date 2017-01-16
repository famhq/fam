z = require 'zorium'
Environment = require 'clay-environment'

PrimaryButton = require '../primary_button'
FlatButton = require '../flat_button'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class GetApp
  constructor: ({@model, @router, serverData}) ->
    @$downloadButton = new PrimaryButton()
    @$downloadAltButton = new PrimaryButton()
    @$skipButton = new FlatButton()

    @state = z.state {serverData}

  render: =>
    {serverData} = @state.getValue()

    userAgent = navigator?.userAgent or serverData?.req?.headers?['user-agent']

    z '.z-get-app',
      z '.content',
        z '.inner',
          z '.title', 'Now, get the app'
          z '.description',
            z 'p', 'Thank you, your registration is complete'
            z 'p',
              'You can use Starfire from a browser, but it\'s best to
              install the app'

          z '.icon'

          z '.buttons',
            unless Environment.isAndroid {userAgent}
              z '.button',
                z @$downloadButton,
                  text: 'Download the app (iOS)'
                  onclick: =>
                    @model.portal.call 'browser.openWindow',
                      url: config.IOS_APP_URL
                      target: '_system'

            unless Environment.isiOS {userAgent}
              z '.button',
                z @$downloadAltButton,
                  text: 'Download the app (Android)'
                  onclick: =>
                    @model.portal.call 'browser.openWindow',
                      url: config.GOOGLE_PLAY_APP_URL
                      target: '_system'

            z '.button',
              z @$skipButton,
                text: 'Skip'
                onclick: =>
                  @router.go '/'
