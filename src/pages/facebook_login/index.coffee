z = require 'zorium'
_defaults = require 'defaults'
Environment = require 'clay-environment'

Head = require '../../components/head'
Spinner = require '../../components/spinner'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class FacebookLoginPage
  constructor: ({@model, requests, serverData, router}) ->
    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'facebookLoginPage.title'
        description: @model.l.get 'facebookLoginPage.contentTitle'
      }
    })
    @$spinner = new Spinner()

    @state = z.state
      windowSize: @model.window.getSize()
      ignore: requests.map ({route, req}) =>
        facebookAccessToken = req.query.access_token
        type = route.params.type

        if type is 'native'
          data = {
            facebookAccessToken: facebookAccessToken
          }
          data = encodeURIComponent JSON.stringify data
          window?.location.href =
            "#{config.GAME_KEY}://_facebookLogin/facebook.login/#{data}"

        else if facebookAccessToken
          @model.auth.loginFacebook @model, {facebookAccessToken}
          .then ->
            router?.go '/'

        else
          router?.go '/'

  renderHead: (params) =>
    z @$head, params

  render: =>
    {windowSize} = @state.getValue()

    z '.p-facebook-login', {
      style:
        height: "#{windowSize.height}px"
    },
      z '.content',
        z '.spinner', @$spinner
        z '.title', @model.l.get 'facebookLoginPage.contentTitle'
        z '.description', @model.l.get 'facebookLoginPage.contentDescription'
