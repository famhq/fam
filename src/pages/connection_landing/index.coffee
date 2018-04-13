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
        token = req.query.access_token
        appKey = req.query.app_key
        unless token
          query = qs.parse window.location.hash?.replace('#', '')
          token = query?.access_token
          state = try
            JSON.parse query?.state
          catch err
          appKey = state?.appKey
        site = route.params.site
        appKey = state?.appKey or 'browser'

        data = encodeURIComponent JSON.stringify {token}
        path = "#{appKey}://_connectionLanding/#{site}/#{data}"

        if appKey isnt 'browser'
          window?.location.href = path
        else
          console.log 'route', window.opener.onRoute
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
