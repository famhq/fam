z = require 'zorium'

Head = require '../../components/head'
Policies = require '../../components/policies'

if window?
  require './index.styl'

module.exports = class PoliciesPage
  hideDrawer: true
  isPublic: true

  constructor: ({model, requests, @router, serverData}) ->
    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: 'Policies'
        description: 'Policies'
      }
    })
    @$policies = new Policies {model, @router}

    @state = z.state
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-policies', {
      style:
        height: "#{windowSize.height}px"
    },
      @$policies
