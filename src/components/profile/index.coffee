z = require 'zorium'

Tabs = require '../tabs'
Icon = require '../icon'
ProfileInfo = require '../profile_info'
ProfileDecks = require '../profile_decks'
ProfileMatches = require '../profile_matches'
ProfileGraphs = require '../profile_graphs'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class Profile
  constructor: ({@model, @router, user, @overlay$}) ->
    me = @model.user.getMe()

    @$tabs = new Tabs {@model}
    @$infoIcon = new Icon()
    @$historyIcon = new Icon()
    @$decksIcon = new Icon()
    @$graphIcon = new Icon()

    @$profileInfo = new ProfileInfo {@model, @router, user, @overlay$}
    @$profileDecks = new ProfileDecks {@model, @router, user}
    @$profileMatches = new ProfileMatches {@model, @router, user}
    @$profileGraphs = new ProfileGraphs {@model, @router, user}

    @state = z.state
      me: me

  render: ({isOtherProfile} = {}) =>
    {me} = @state.getValue()

    z '.z-profile',
      z @$tabs,
        isBarFixed: false
        isBarFlat: false
        barStyle: 'primary'
        tabs: [
          {
            $menuIcon: @$infoIcon
            menuIconName: 'info'
            $menuText: 'Info'
            $el: @$profileInfo
          }
          # {
          #   $menuIcon: @$historyIcon
          #   menuIconName: 'history'
          #   $menuText: 'Matches'
          #   $el: @$profileMatches
          # }
          {
            $menuIcon: @$decksIcon
            menuIconName: 'decks'
            $menuText: 'Decks'
            $el: @$profileDecks
          }
          {
            $menuIcon: @$graphIcon
            menuIconName: 'stats'
            $menuText: 'Graphs'
            $el: @$profileGraphs
          }
        ]
