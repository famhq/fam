z = require 'zorium'

GroupNewLfg = require '../../components/group_new_lfg'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupNewLfgPage
  isGroup: true
  hideDrawer: true

  constructor: ({@model, requests, @router, serverData, group}) ->
    @$groupNewLfg = new GroupNewLfg {
      @model
      @router
      group
    }

    @state = z.state
      group: group
      windowSize: @model.window.getSize()

  getMeta: =>
    {
      title: @model.l.get 'groupNewLfgPage.title'
      description: @model.l.get 'groupNewLfgPage.title'
    }

  render: =>
    {group, windowSize, titleValue, bodyValue} = @state.getValue()

    z '.p-group-new-lfg', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$groupNewLfg
