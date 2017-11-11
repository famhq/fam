z = require 'zorium'
isUuid = require 'isuuid'

Head = require '../../components/head'
GroupManageRecords = require '../../components/group_manage_records'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupManageRecordsPage
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
        title: 'Manage Records'
        description: 'Manage Records'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@model, @router}
    @$groupManageRecords = new GroupManageRecords {
      model, @router, serverData, group
    }

    @state = z.state
      windowSize: model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-group-manage-records', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: 'Manage Records'
        style: 'primary'
        isFlat: true
        $topLeftButton: z @$buttonBack, {color: colors.$primary500}
      }
      @$groupManageRecords
