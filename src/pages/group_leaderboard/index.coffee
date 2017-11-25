z = require 'zorium'
isUuid = require 'isuuid'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
Tabs = require '../../components/tabs'
GroupLeaderboard = require '../../components/group_leaderboard'
GroupEarnXp = require '../../components/group_earn_xp'
ButtonMenu = require '../../components/button_menu'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupLeaderboardPage
  isGroup: true

  constructor: ({@model, requests, @router, serverData}) ->
    group = requests.switchMap ({route}) =>
      if isUuid route.params.id
        @model.group.getById route.params.id
      else
        @model.group.getByKey route.params.id

    gameKey = requests.map ({route}) ->
      route.params.gameKey or config.DEFAULT_GAME_KEY

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'leaderboardPage.title'
        description: @model.l.get 'leaderboardPage.title'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model, @router}
    @$tabs = new Tabs {@model}
    @$groupLeaderboard = new GroupLeaderboard {
      @model, @router, serverData, group, gameKey
    }
    @$earnXp = new GroupEarnXp {
      @model, @router, serverData, group, gameKey
    }

    @state = z.state
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-group-leaderboard', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'groupLeaderboardPage.title'
        isFlat: true
        $topLeftButton: z @$buttonMenu, {
          color: colors.$primary500
        }
      }
      z @$tabs,
        isBarFixed: false
        hasAppBar: true
        tabs: [
          {
            $menuText: @model.l.get 'groupLeaderboardPage.topAllTime'
            $el: z @$groupLeaderboard
          }
          {
            $menuText: @model.l.get 'groupLeaderboardPage.earnXp'
            $el: z @$earnXp
          }
        ]
