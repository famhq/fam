z = require 'zorium'

GroupNewPage = require '../../components/group_new_page'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupNewPagePage
  isGroup: true

  constructor: ({@model, requests, @router, serverData, group}) ->
    @$groupNewPage = new GroupNewPage {
      @model
      @router
      group
    }

    @state = z.state
      group: group
      windowSize: @model.window.getSize()

  getMeta: =>
    {
      title: @model.l.get 'groupNewPagePage.title'
    }

  render: =>
    {group, windowSize, titleValue, bodyValue} = @state.getValue()

    z '.p-group-new-page', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$groupNewPage
