z = require 'zorium'

Policies = require '../../components/policies'

if window?
  require './index.styl'

module.exports = class PoliciesPage
  hideDrawer: true

  constructor: ({@model, requests, @router, serverData, group}) ->
    @$policies = new Policies {@model, @router}

    @state = z.state
      windowSize: @model.window.getSize()

  getMeta: =>
    {
      title: @model.l.get 'policiesPage.title'
      description: @model.l.get 'policiesPage.title'
    }

  render: =>
    {windowSize} = @state.getValue()

    z '.p-policies', {
      style:
        height: "#{windowSize.height}px"
    },
      @$policies
