z = require 'zorium'

Tabs = require '../tabs'
Icon = require '../icon'
ProfileInfo = require '../profile_info'
ProfileHistory = require '../profile_history'
ProfileGraphs = require '../profile_graphs'

if window?
  require './index.styl'

module.exports = class Profile
  constructor: ({@model, @router}) ->
    me = @model.user.getMe()

    @$tabs = new Tabs {@model}
    @$infoIcon = new Icon()
    @$historyIcon = new Icon()
    @$graphIcon = new Icon()

    @$profileInfo = new ProfileInfo {@model, @router}
    @$profileHistory = new ProfileHistory {@model, @router}
    @$profileGraphs = new ProfileGraphs {@model, @router}

    @state = z.state
      me: me

  render: =>
    {me} = @state.getValue()

    z '.z-profile',
      z @$tabs,
        isBarFixed: false
        tabs: [
          {
            $menuIcon: @$infoIcon
            menuIconName: 'info'
            $menuText: 'Info'
            $el: @$profileInfo
          }
          {
            $menuIcon: @$historyIcon
            menuIconName: 'history'
            $menuText: 'History'
            $el: @$profileHistory
          }
          {
            $menuIcon: @$graphIcon
            menuIconName: 'stats'
            $menuText: 'Graphs'
            $el: @$profileGraphs
          }
        ]
