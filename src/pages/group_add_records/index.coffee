z = require 'zorium'

Head = require '../../components/head'
GroupAddRecords = require '../../components/group_add_records'
ButtonBack = require '../../components/button_back'
Icon = require '../../components/icon'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupAddRecordsPage
  hideDrawer: true

  constructor: ({model, requests, @router, serverData}) ->
    group = requests.flatMapLatest ({route}) ->
      model.group.getById route.params.id

    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: 'Add Records'
        description: 'Add Records'
      }
    })
    @$buttonBack = new ButtonBack {@model, @router}
    @$manageIcon = new Icon()
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
