z = require 'zorium'
Rx = require 'rx-lite'
Button = require 'zorium-paper/button'

config = require '../../config'
colors = require '../../colors'
Head = require '../../components/head'
EditGroup = require '../../components/edit_group'

if window?
  require './index.styl'

module.exports = class NewGroupPage
  hideDrawer: true

  constructor: ({model, requests, @router, serverData}) ->
    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: 'New Group'
        description: 'New Group'
      }
    })
    @$editGroup = new EditGroup {model, @router, serverData}

  renderHead: => @$head

  render: =>
    z '.p-edit-group', {
      style:
        height: "#{window?.innerHeight}px"
    },
      z @$editGroup, {isNewGroup: true}
