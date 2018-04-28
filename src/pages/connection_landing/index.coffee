z = require 'zorium'
qs = require 'qs'
_defaults = require 'lodash/defaults'

Spinner = require '../../components/spinner'
Environment = require '../../services/environment'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class ConnectionLandingPage
  constructor: ({@model, requests, portal, router}) ->
    @$spinner = new Spinner()

    if window?
      requests.take(1).subscribe ({route, req}) =>
        hashQuery = qs.parse window.location.hash?.replace('#', '')
        site = route.params.site
        code = req.query.code or hashQuery?.code
        idToken = req.query.id_token or hashQuery?.id_token
        state = try
          JSON.parse(query?.state or decodeURIComponent(hashQuery?.state))
        catch err
        appKey = state?.appKey or 'browser'

        console.log hashQuery

        data = encodeURIComponent JSON.stringify {code, idToken}
        path = "#{appKey}://_connectionLanding/#{site}/#{data}"

        if appKey isnt 'browser'
          window?.location.href = path
        else
          window.opener.onRoute path
          setImmediate ->
            window.close()
        # else if token
        #   @model.connection.create {
        #     site: site
        #     token: token
        #   }
        #   .then ->
        #     router?.go '/'
        #
        # else
        #   router?.go '/'

  getMeta: ->
    {}

  render: =>
    z '.p-connection-landing', {
      style:
        height: "#{window?.innerHeight}px"
    },
      z '.content',
        z '.spinner', @$spinner
        z '.title', @model.l.get 'connectionLandingPage.title'
        z '.description', 'Just a moment'
