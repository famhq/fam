z = require 'zorium'

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
    z '.p-new-group', {
      style:
        height: "#{window?.innerHeight}px"
    },
      z @$editGroup, {isNewGroup: true}
