z = require 'zorium'
isUuid = require 'isuuid'

Head = require '../../components/head'
GroupAddRecords = require '../../components/group_add_records'

if window?
  require './index.styl'

module.exports = class GroupAddRecordsPage
  hideDrawer: true
  isGroup: true

  constructor: ({model, requests, @router, serverData}) ->
    group = requests.switchMap ({route}) ->
      if isUuid route.params.id
        model.group.getById route.params.id
      else
        model.group.getByKey route.params.id

    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: 'Add Records'
        description: 'Add Records'
      }
    })
    @$groupAddRecords = new GroupAddRecords {
      model, @router, serverData, group
    }

    @state = z.state
      group: group
      windowSize: model.window.getSize()

  renderHead: => @$head

  render: =>
    {group, windowSize} = @state.getValue()

    z '.p-group-add-records', {
      style:
        height: "#{windowSize.height}px"
    },
      @$groupAddRecords
