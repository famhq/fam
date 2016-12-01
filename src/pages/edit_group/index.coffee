z = require 'zorium'
Rx = require 'rx-lite'
Button = require 'zorium-paper/button'
_ = require 'lodash'

config = require '../../config'
colors = require '../../colors'
Head = require '../../components/head'
EditGroup = require '../../components/edit_group'

if window?
  require './index.styl'

module.exports = class EditGroupPage
  hideDrawer: true

  constructor: ({model, requests, @router, serverData}) ->
    group = requests.flatMapLatest ({route}) ->
      model.group.getById route.params.id

    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: 'Edit Group'
        description: 'Edit Group'
      }
    })
    @$editGroup = new EditGroup {model, @router, serverData, group}

  renderHead: => @$head

  render: =>
    z '.p-edit-group', {
      style:
        height: "#{window?.innerHeight}px"
    },
      @$editGroup
