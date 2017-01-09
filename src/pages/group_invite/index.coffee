z = require 'zorium'

Head = require '../../components/head'
GroupInvite = require '../../components/group_invite'

if window?
  require './index.styl'

module.exports = class GroupInvitePage
  hideDrawer: true

  constructor: ({model, requests, @router, serverData}) ->
    group = requests.flatMapLatest ({route}) ->
      model.group.getById route.params.id

    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: 'Group Invite'
        description: 'Group Invite'
      }
    })
    @$groupInvite = new GroupInvite {model, @router, serverData, group}

    @state = z.state
      windowSize: model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-group-invite', {
      style:
        height: "#{windowSize.height}px"
    },
      @$groupInvite
