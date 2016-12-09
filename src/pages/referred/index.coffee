z = require 'zorium'
Rx = require 'rx-lite'
Button = require 'zorium-paper/button'

config = require '../../config'
colors = require '../../colors'
Head = require '../../components/head'
Referred = require '../../components/referred'

if window?
  require './index.styl'

module.exports = class ReferredPage
  hideDrawer: true
  isPublic: true

  constructor: ({model, requests, @router, serverData}) ->
    referrer = requests.flatMapLatest ({route}) ->
      if route.params.userId
        localStorage?['referrerId'] = route.params.userId
      model.user.getById(route.params.userId or localStorage?['referrerId'])

    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: 'Join Red Tritium'
        description: 'Join Red Tritium'
      }
    })
    @$referred = new Referred {model, @router, referrer}

  renderHead: => @$head

  render: =>
    z '.p-referred', {
      style:
        height: "#{window?.innerHeight}px"
    },
      @$referred
