z = require 'zorium'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
ProfileChest = require '../../components/profile_chests'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class ProfileChestsPage
  hideDrawer: true
  hasBottomBanner: true

  constructor: ({@model, requests, @router, serverData}) ->
    id = requests.map ({route}) ->
      if route.params.id then route.params.id else false

    player = id.flatMapLatest (id) =>
      @model.player.getByUserIdAndGameId id, config.CLASH_ROYALE_ID
      .map (player) ->
        return player or {}

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'profileChestsPage.title'
        description: @model.l.get 'profileChestsPage.title'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@model, @router}
    @$profileChest = new ProfileChest {@model, @router, player}

    @state = z.state
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-profile-chests', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'profileChestsPage.title'
        style: 'secondary'
        $topLeftButton: z @$buttonBack, {color: colors.$primary500}
      }
      @$profileChest
