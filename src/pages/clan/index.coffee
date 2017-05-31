z = require 'zorium'
Rx = require 'rx-lite'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
Clan = require '../../components/clan'
BottomBar = require '../../components/bottom_bar'
Spinner = require '../../components/spinner'
Icon = require '../../components/icon'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class ClanPage
  constructor: ({@model, requests, @router, serverData}) ->
    id = requests.map ({route}) ->
      if route.params.id then route.params.id else false

    me = @model.user.getMe()
    gameData = me.flatMapLatest ({id}) =>
      @model.player.getByUserIdAndGameId id, config.CLASH_ROYALE_ID

    gameDataAndId = Rx.Observable.combineLatest(gameData, id, (vals...) -> vals)

    clan = gameDataAndId.flatMapLatest ([gameData, id]) =>
      if id
        @model.clan.getById id
        .map (clan) -> clan or false
      else if gameData?.data?.clan?.tag
        @model.clan.getById gameData?.data?.clan?.tag
        .map (clan) -> clan or false
      else
        Rx.Observable.just false

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'general.clan'
        description: @model.l.get 'general.clan'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model}
    @$spinner = new Spinner()
    @$settingsIcon = new Icon()

    @$clan = new Clan {@model, @router, clan}
    @$bottomBar = new BottomBar {@model, @router, requests}

    @state = z.state
      windowSize: @model.window.getSize()
      clan: clan
      me: @model.user.getMe()

  renderHead: => @$head

  render: =>
    {windowSize, clan, me} = @state.getValue()

    z '.p-clan', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'general.clan'
        isFlat: true
        $topLeftButton: z @$buttonMenu, {color: colors.$primary500}
        $topRightButton: z '.p-clan_top-right',
          if clan and clan?.creatorId is me?.id
            z @$settingsIcon, {
              icon: 'settings'
              color: colors.$tertiary900
              onclick: =>
                @router.go "/group/#{clan?.group?.id}/settings"
              }
      }
      if clan
        @$clan
      else if clan is false
        z '.empty', @model.l.get 'clanPage.empty'
      else
        @$spinner
      @$bottomBar
