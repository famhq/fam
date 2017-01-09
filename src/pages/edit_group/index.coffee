z = require 'zorium'

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

    @state = z.state
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-edit-group', {
      style:
        height: "#{windowSize.height}px"
    },
      @$editGroup
